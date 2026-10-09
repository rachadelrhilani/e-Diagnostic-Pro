package com.teleexpertise.controller;

import com.teleexpertise.dao.*;
import com.teleexpertise.dto.CreneauHoraireDTO;
import com.teleexpertise.model.*;
import com.teleexpertise.service.SpecialisteService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/specialiste/*")
public class SpecialisteServlet extends HttpServlet {

    private SpecialisteService specialisteService;

    @Override
    public void init() throws ServletException {
        UtilisateurDao utilisateurDao = new UtilisateurDao();
        CreneauDao creneauDao = new CreneauDao();
        DemandeExpertiseDao demandeExpertiseDao = new DemandeExpertiseDao();
        SpecialisteDao specialisteDao = new SpecialisteDao();

        this.specialisteService = new SpecialisteService(
                utilisateurDao, 
                creneauDao, 
                demandeExpertiseDao,
                specialisteDao
        );
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        Utilisateur user = (Utilisateur) req.getSession().getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        if (path == null || "/dashboard".equals(path) || "/demandes".equals(path)) {
            String statutStr = req.getParameter("statut");
            String prioriteStr = req.getParameter("priorite");

            StatutExpertise statut = (statutStr != null && !statutStr.trim().isEmpty()) ? StatutExpertise.valueOf(statutStr.trim()) : null;
            Priorite priorite = (prioriteStr != null && !prioriteStr.trim().isEmpty()) ? Priorite.valueOf(prioriteStr.trim()) : null;

            // 1. Récupération des demandes filtrées via Stream API (US7)
            List<DemandeExpertise> demandes = specialisteService.consulterDemandesFiltrees(user.getId(), statut, priorite);
            
            // 2. Récupération de l'ensemble des demandes pour calculer les KPIs
            List<DemandeExpertise> toutesLesDemandes = specialisteService.consulterDemandesFiltrees(user.getId(), null, null);
            List<Creneau> creneaux = specialisteService.consulterCreneaux(user.getId());

            // 3. Calculs dynamiques via Stream API
            long demandesEnAttenteCount = toutesLesDemandes.stream()
                    .filter(d -> d.getStatut() == StatutExpertise.EN_ATTENTE)
                    .count();

            long avisRendusCount = toutesLesDemandes.stream()
                    .filter(d -> d.getStatut() == StatutExpertise.TERMINEE)
                    .count();

            long creneauxDispoCount = creneaux.stream()
                    .filter(c -> c.getStatut() == StatutCreneau.DISPONIBLE)
                    .count();

            // 4. Transmission à la vue JSP
            req.setAttribute("demandes", demandes);
            req.setAttribute("demandesEnAttenteCount", demandesEnAttenteCount);
            req.setAttribute("avisRendusCount", avisRendusCount);
            req.setAttribute("creneauxDispoCount", creneauxDispoCount);
            req.setAttribute("selectedStatut", statutStr);
            req.setAttribute("selectedPriorite", prioriteStr);

            req.getRequestDispatcher("/WEB-INF/views/specialiste/dashboard.jsp").forward(req, resp);

        } else if ("/expertise".equals(path)) {
            // US7 & US8: Consulter le dossier complet d'une demande et répondre
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    Long demandeId = Long.parseLong(idStr.trim());
                    DemandeExpertise demande = specialisteService.getDemandeComplete(demandeId);
                    if (demande != null) {
                        req.setAttribute("demande", demande);
                        req.getRequestDispatcher("/WEB-INF/views/specialiste/expertise.jsp").forward(req, resp);
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/specialiste/dashboard?error=Demande+introuvable");

        } else if ("/creneaux".equals(path)) {
            // US6: Visualiser ses créneaux et configurer ses disponibilités journalières
            String dateParam = req.getParameter("date");
            LocalDate selectedDate = LocalDate.now();
            if (dateParam != null && !dateParam.trim().isEmpty()) {
                try {
                    selectedDate = LocalDate.parse(dateParam.trim());
                } catch (DateTimeParseException ignored) {}
            }

            // Récupérer la grille horaire avec statut automatique (désactivé si heure passée pour aujourd'hui)
            List<CreneauHoraireDTO> grille = specialisteService.getGrilleDisponibilites(user.getId(), selectedDate);
            List<Creneau> creneaux = specialisteService.consulterCreneaux(user.getId());

            req.setAttribute("selectedDate", selectedDate.toString());
            req.setAttribute("todayDate", LocalDate.now().toString());
            req.setAttribute("grille", grille);
            req.setAttribute("creneaux", creneaux);

            req.getRequestDispatcher("/WEB-INF/views/specialiste/creneaux.jsp").forward(req, resp);

        } else if ("/profil".equals(path)) {
            // US5: Configurer son profil
            Specialiste sp = specialisteService.getSpecialiste(user.getId());
            req.setAttribute("specialiste", sp);
            req.getRequestDispatcher("/WEB-INF/views/specialiste/profil.jsp").forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/specialiste/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();
        Utilisateur user = (Utilisateur) req.getSession().getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        if ("/configurer-profil".equals(action)) {
            // US5: Définir son tarif, sa spécialité, durée moyenne fixe 30 min
            try {
                String specialite = req.getParameter("specialite");
                double tarif = Double.parseDouble(req.getParameter("tarif"));

                specialisteService.configurerProfil(user.getId(), specialite, tarif);

                // Rafraîchir l'utilisateur en session
                Specialiste updated = specialisteService.getSpecialiste(user.getId());
                if (updated != null) {
                    req.getSession().setAttribute("user", updated);
                }

                resp.sendRedirect(req.getContextPath() + "/specialiste/profil?msg=" +
                        URLEncoder.encode("Profil mis à jour avec succès", StandardCharsets.UTF_8));
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/specialiste/profil?error=" +
                        URLEncoder.encode("Erreur lors de la mise à jour : " + e.getMessage(), StandardCharsets.UTF_8));
            }

        } else if ("/creer-disponibilites".equals(action)) {
            // US6: Création de créneaux avec désactivation des créneaux passés
            try {
                String dateStr = req.getParameter("date");
                LocalDate date = (dateStr != null && !dateStr.trim().isEmpty()) ? LocalDate.parse(dateStr.trim()) : LocalDate.now();

                String[] heuresArr = req.getParameterValues("heures");
                List<LocalTime> heuresList = new ArrayList<>();
                if (heuresArr != null) {
                    for (String h : heuresArr) {
                        try {
                            heuresList.add(LocalTime.parse(h.trim()));
                        } catch (DateTimeParseException ignored) {}
                    }
                }

                int crees = specialisteService.creerDisponibilites(user.getId(), date, heuresList);
                resp.sendRedirect(req.getContextPath() + "/specialiste/creneaux?date=" + date + "&msg=" +
                        URLEncoder.encode(crees + " créneau(x) de disponibilité enregistré(s) avec succès (durée fixe 30 min).", StandardCharsets.UTF_8));
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/specialiste/creneaux?error=" +
                        URLEncoder.encode("Erreur : " + e.getMessage(), StandardCharsets.UTF_8));
            }

        } else if ("/annuler-creneau".equals(action)) {
            // US6: Supprimer un créneau encore disponible
            try {
                Long creneauId = Long.parseLong(req.getParameter("creneauId"));
                boolean supprime = specialisteService.supprimerCreneau(creneauId, user.getId());
                if (supprime) {
                    resp.sendRedirect(req.getContextPath() + "/specialiste/creneaux?msg=" +
                            URLEncoder.encode("Créneau supprimé avec succès.", StandardCharsets.UTF_8));
                } else {
                    resp.sendRedirect(req.getContextPath() + "/specialiste/creneaux?error=" +
                            URLEncoder.encode("Impossible de supprimer ce créneau (il n'est plus disponible ou n'existe pas).", StandardCharsets.UTF_8));
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/specialiste/creneaux?error=" +
                        URLEncoder.encode("Erreur : " + e.getMessage(), StandardCharsets.UTF_8));
            }

        } else if ("/annuler-expertise".equals(action)) {
            // US6/US8: Annuler une demande en attente ou un avis déjà rendu -> créneau libéré
            try {
                Long demandeId = Long.parseLong(req.getParameter("demandeId"));
                specialisteService.annulerDemandeExpertise(demandeId);
                resp.sendRedirect(req.getContextPath() + "/specialiste/expertise?id=" + demandeId + "&msg=" +
                        URLEncoder.encode("Avis annulé. Le créneau est de nouveau disponible.", StandardCharsets.UTF_8));
            } catch (Exception e) {
                String fallback = req.getParameter("demandeId");
                String target = (fallback != null && !fallback.trim().isEmpty())
                        ? req.getContextPath() + "/specialiste/expertise?id=" + fallback.trim() + "&error="
                        : req.getContextPath() + "/specialiste/dashboard?error=";
                resp.sendRedirect(target + URLEncoder.encode("Erreur : " + e.getMessage(), StandardCharsets.UTF_8));
            }

        } else if ("/repondre-expertise".equals(action)) {
            // US8: Répondre à une expertise (avis médical, recommandations, terminer)
            try {
                Long demandeId = Long.parseLong(req.getParameter("demandeId"));
                String avisMedical = req.getParameter("avisMedical");
                String recommandations = req.getParameter("recommandations");

                if (avisMedical == null || avisMedical.trim().isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/specialiste/expertise?id=" + demandeId + "&error=" +
                            URLEncoder.encode("L'avis médical est obligatoire.", StandardCharsets.UTF_8));
                    return;
                }

                specialisteService.repondreAExpertise(demandeId, avisMedical.trim(), (recommandations != null ? recommandations.trim() : ""));
                resp.sendRedirect(req.getContextPath() + "/specialiste/expertise?id=" + demandeId + "&msg=" +
                        URLEncoder.encode("Avis médical et recommandations transmis avec succès. Expertise marquée comme terminée.", StandardCharsets.UTF_8));
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/specialiste/dashboard?error=" +
                        URLEncoder.encode("Erreur : " + e.getMessage(), StandardCharsets.UTF_8));
            }
        }
    }
}
package com.teleexpertise.controller;

import com.teleexpertise.dao.*;
import com.teleexpertise.model.*;
import com.teleexpertise.service.GeneralisteService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/generaliste/*")
public class GeneralisteServlet extends HttpServlet {

    private GeneralisteService generalisteService;

    @Override
    public void init() throws ServletException {
        // Instanciation et injection de toutes les dépendances DAO
        ConsultationDao consultationDao = new ConsultationDao();
        SpecialisteDao specialisteDao = new SpecialisteDao();
        CreneauDao creneauDao = new CreneauDao();
        DemandeExpertiseDao demandeExpertiseDao = new DemandeExpertiseDao();
        PatientDao patientDao = new PatientDao();

        this.generalisteService = new GeneralisteService(
                consultationDao, 
                specialisteDao, 
                creneauDao, 
                demandeExpertiseDao,
                patientDao
        );
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();

        if (path == null || "/dashboard".equals(path)) {
            // US1: 1. Récupérer tous les patients existants pour nouvelle consultation
            List<Patient> tousLesPatients = generalisteService.getAllPatients();
            req.setAttribute("tousLesPatients", tousLesPatients);

            // Récupérer les patients en attente
            List<Patient> patientsEnAttente = generalisteService.getPatientsEnAttente();
            req.setAttribute("patientsEnAttente", patientsEnAttente);

            // 2. Récupérer les consultations en cours du généraliste connecté
            Utilisateur user = (Utilisateur) req.getSession().getAttribute("user");
            System.out.println("Utilisateur connecté : " + user);
            if (user != null) {
                // Toutes les actives (EN_COURS + EN_ATTENTE) pour le tableau,
                // et uniquement EN_COURS pour le blocage du formulaire de création
                List<Consultation> mesConsultations = generalisteService.getConsultationsEnCoursParGeneraliste(user.getId());
                req.setAttribute("mesConsultations", mesConsultations);
                List<Consultation> consultationsBlocantes = generalisteService.getConsultationsEnCoursStrictParGeneraliste(user.getId());
                req.setAttribute("consultationBlocante", consultationsBlocantes.isEmpty() ? null : consultationsBlocantes.get(0));
            }

            req.getRequestDispatcher("/WEB-INF/views/generaliste/dashboard.jsp").forward(req, resp);

        } else if ("/recherche-specialiste".equals(path)) {
            // US3: Choisir une spécialité et filtrer via Stream API par spécialité et tarif
            String consultationIdStr = req.getParameter("consultationId");
            String fromConsultationStr = req.getParameter("fromConsultation");
            boolean fromConsultation = "true".equalsIgnoreCase(fromConsultationStr);

            Long consultationId = null;
            if (consultationIdStr != null && !consultationIdStr.trim().isEmpty()) {
                try {
                    consultationId = Long.parseLong(consultationIdStr.trim());
                    Consultation consultation = generalisteService.getConsultationComplete(consultationId);
                    req.setAttribute("consultation", consultation);
                    req.setAttribute("consultationId", consultationId);
                } catch (NumberFormatException ignored) {}
            }

            Utilisateur user = (Utilisateur) req.getSession().getAttribute("user");
            if (user != null) {
                // Page recherche : uniquement les consultations EN_COURS (pas EN_ATTENTE_AVIS_SPECIALISTE)
                List<Consultation> consultationsEnCours = generalisteService.getConsultationsEnCoursStrictParGeneraliste(user.getId());
                req.setAttribute("consultationsEnCours", consultationsEnCours);
            }
            req.setAttribute("fromConsultation", fromConsultation);

            String specialite = req.getParameter("specialite");
            String maxTarifStr = req.getParameter("maxTarif");
            Double maxTarif = (maxTarifStr != null && !maxTarifStr.trim().isEmpty()) ? Double.parseDouble(maxTarifStr.trim()) : null;

            List<String> specialitesDisponibles = generalisteService.getSpecialitesDisponibles();
            req.setAttribute("specialitesDisponibles", specialitesDisponibles);

            List<Specialiste> specialistes = generalisteService.rechercherEtTrierSpecialistes(specialite, maxTarif);
            req.setAttribute("specialistes", specialistes);
            req.setAttribute("selectedSpecialite", specialite);
            req.setAttribute("selectedMaxTarif", maxTarif);

            req.getRequestDispatcher("/WEB-INF/views/generaliste/recherche_specialiste.jsp").forward(req, resp);

        } else if ("/creneaux".equals(path)) {
            // US3: Voir les créneaux disponibles (horaires fixes prédéfinis)
            Long specialisteId = Long.parseLong(req.getParameter("specialisteId"));
            String consultationIdStr = req.getParameter("consultationId");

            Specialiste specialiste = generalisteService.getSpecialiste(specialisteId);
            List<Creneau> creneaux = generalisteService.getCreneauxDisponibles(specialisteId);

            if (consultationIdStr != null && !consultationIdStr.trim().isEmpty()) {
                Long consultationId = Long.parseLong(consultationIdStr.trim());
                Consultation consultation = generalisteService.getConsultationComplete(consultationId);
                req.setAttribute("consultation", consultation);
                req.setAttribute("consultationId", consultationId);
            }

            req.setAttribute("specialiste", specialiste);
            req.setAttribute("creneaux", creneaux);
            req.setAttribute("specialisteId", specialisteId);

            req.getRequestDispatcher("/WEB-INF/views/generaliste/choix_creneau.jsp").forward(req, resp);

        } else if ("/detail-consultation".equals(path) || "/consultation".equals(path)) {
            // US1, US3, US4: Détail complet de la consultation & Coût total (Lambda map().sum())
            Long consultationId = Long.parseLong(req.getParameter("id"));
            Consultation consultation = generalisteService.getConsultationComplete(consultationId);
            double coutTotal = generalisteService.calculerCoutTotal(consultationId);

            req.setAttribute("consultation", consultation);
            req.setAttribute("coutTotal", coutTotal);

            req.getRequestDispatcher("/WEB-INF/views/generaliste/detail_consultation.jsp").forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/generaliste/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();
        Utilisateur user = (Utilisateur) req.getSession().getAttribute("user");

        if ("/creer-consultation".equals(action)) {
            // US1: Créer une consultation (Sélectionner patient, saisir motif/obs, coût fixe 150 DH)
            Long patientId = Long.parseLong(req.getParameter("patientId"));
            String motif = req.getParameter("motif");
            String observations = req.getParameter("observations");

            try {
                Consultation c = generalisteService.creerConsultation(patientId, user.getId(), motif, observations);
                resp.sendRedirect(req.getContextPath() + "/generaliste/detail-consultation?id=" + c.getId() + "&msg=Consultation+initialisee+(150+DH)");
            } catch (IllegalStateException e) {
                resp.sendRedirect(req.getContextPath() + "/generaliste/dashboard?error=" +
                        java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }

        } else if ("/cloturer-directe".equals(action)) {
            Long consultationId = Long.parseLong(req.getParameter("consultationId"));
            String diagnostic = req.getParameter("diagnostic");
            String traitement = req.getParameter("traitement");

            generalisteService.cloturerConsultationDirecte(consultationId, diagnostic, traitement);
            resp.sendRedirect(req.getContextPath() + "/generaliste/detail-consultation?id=" + consultationId + "&msg=Consultation+cloturee+avec+succes");

        } else if ("/envoyer-demande-expertise".equals(action)) {
            // US3: Sélectionner un créneau, poser une question au spécialiste et fournir données & analyses
            Long consultationId = Long.parseLong(req.getParameter("consultationId"));
            Long specialisteId = Long.parseLong(req.getParameter("specialisteId"));
            Long creneauId = Long.parseLong(req.getParameter("creneauId"));
            String question = req.getParameter("question");
            String donneesAnalyses = req.getParameter("donneesAnalyses");

            if (donneesAnalyses != null && !donneesAnalyses.trim().isEmpty()) {
                question = question + "\n\n[Données cliniques & analyses fournies] :\n" + donneesAnalyses.trim();
            }

            String prioriteStr = req.getParameter("priorite");
            Priorite priorite = (prioriteStr != null && !prioriteStr.trim().isEmpty())
                    ? Priorite.valueOf(prioriteStr.trim())
                    : Priorite.NORMALE;

            generalisteService.demanderExpertise(consultationId, specialisteId, creneauId, question, priorite);
            resp.sendRedirect(req.getContextPath() + "/generaliste/detail-consultation?id=" + consultationId + "&msg=Demande+de+tele-expertise+envoyee+au+specialiste");

        } else if ("/ajouter-acte".equals(action)) {
            // US4: Ajouter un acte technique médical pour calcul du coût total
            Long consultationId = Long.parseLong(req.getParameter("consultationId"));
            String nomActe = req.getParameter("nomActe");
            double tarifActe = Double.parseDouble(req.getParameter("tarifActe"));

            generalisteService.ajouterActeMedical(consultationId, new ActeMedical(nomActe, tarifActe));
            resp.sendRedirect(req.getContextPath() + "/generaliste/detail-consultation?id=" + consultationId + "&msg=Acte+technique+ajoute+au+dossier");
        } else {
            resp.sendRedirect(req.getContextPath() + "/generaliste/dashboard");
        }
    }
}
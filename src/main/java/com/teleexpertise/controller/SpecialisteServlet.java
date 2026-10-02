package com.teleexpertise.controller;

import com.teleexpertise.dao.*;
import com.teleexpertise.model.*;
import com.teleexpertise.service.SpecialisteService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/specialiste/*")
public class SpecialisteServlet extends HttpServlet {

    private SpecialisteService specialisteService;

    @Override
    public void init() throws ServletException {
        UtilisateurDao utilisateurDao = new UtilisateurDao();
        CreneauDao creneauDao = new CreneauDao();
        DemandeExpertiseDao demandeExpertiseDao = new DemandeExpertiseDao();

        this.specialisteService = new SpecialisteService(
                utilisateurDao, 
                creneauDao, 
                demandeExpertiseDao
        );
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        Utilisateur user = (Utilisateur) req.getSession().getAttribute("user");

        if ("/dashboard".equals(path) || "/demandes".equals(path)) {
            String statutStr = req.getParameter("statut");
            String prioriteStr = req.getParameter("priorite");

            StatutExpertise statut = (statutStr != null && !statutStr.isEmpty()) ? StatutExpertise.valueOf(statutStr) : null;
            Priorite priorite = (prioriteStr != null && !prioriteStr.isEmpty()) ? Priorite.valueOf(prioriteStr) : null;

            List<DemandeExpertise> demandes = specialisteService.consulterDemandesFiltrees(user.getId(), statut, priorite);
            req.setAttribute("demandes", demandes);
            req.getRequestDispatcher("/WEB-INF/views/specialiste/dashboard.jsp").forward(req, resp);

        } else if ("/creneaux".equals(path)) {
            List<Creneau> creneaux = specialisteService.consulterCreneaux(user.getId());
            req.setAttribute("creneaux", creneaux);
            req.getRequestDispatcher("/WEB-INF/views/specialiste/creneaux.jsp").forward(req, resp);

        } else if ("/profil".equals(path)) {
            req.getRequestDispatcher("/WEB-INF/views/specialiste/profil.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();
        Utilisateur user = (Utilisateur) req.getSession().getAttribute("user");

        if ("/configurer-profil".equals(action)) {
            String specialite = req.getParameter("specialite");
            double tarif = Double.parseDouble(req.getParameter("tarif"));

            specialisteService.configurerProfil(user.getId(), specialite, tarif);
            resp.sendRedirect(req.getContextPath() + "/specialiste/profil?msg=Profil+mis+a+jour");

        } else if ("/repondre-expertise".equals(action)) {
            Long demandeId = Long.parseLong(req.getParameter("demandeId"));
            String avisMedical = req.getParameter("avisMedical");
            String recommandations = req.getParameter("recommandations");

            specialisteService.repondreAExpertise(demandeId, avisMedical, recommandations);
            resp.sendRedirect(req.getContextPath() + "/specialiste/demandes?msg=Avis+transmis+avec+succes");
        }
    }
}
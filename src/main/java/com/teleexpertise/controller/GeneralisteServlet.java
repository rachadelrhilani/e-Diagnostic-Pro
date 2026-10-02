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

        this.generalisteService = new GeneralisteService(
                consultationDao, 
                specialisteDao, 
                creneauDao, 
                demandeExpertiseDao
        );
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();

        if ("/dashboard".equals(path)) {
            req.getRequestDispatcher("/WEB-INF/views/generaliste/dashboard.jsp").forward(req, resp);
        } else if ("/recherche-specialiste".equals(path)) {
            String specialite = req.getParameter("specialite");
            String maxTarifStr = req.getParameter("maxTarif");
            Double maxTarif = (maxTarifStr != null && !maxTarifStr.isEmpty()) ? Double.parseDouble(maxTarifStr) : null;

            if (specialite != null) {
                List<Specialiste> specialistes = generalisteService.rechercherEtTrierSpecialistes(specialite, maxTarif);
                req.setAttribute("specialistes", specialistes);
            }
            req.getRequestDispatcher("/WEB-INF/views/generaliste/recherche_specialiste.jsp").forward(req, resp);
        } else if ("/creneaux".equals(path)) {
            Long specialisteId = Long.parseLong(req.getParameter("specialisteId"));
            List<Creneau> creneaux = generalisteService.getCreneauxDisponibles(specialisteId);
            req.setAttribute("creneaux", creneaux);
            req.setAttribute("specialisteId", specialisteId);
            req.setAttribute("consultationId", req.getParameter("consultationId"));
            req.getRequestDispatcher("/WEB-INF/views/generaliste/choix_creneau.jsp").forward(req, resp);
        } else if ("/detail-consultation".equals(path)) {
            Long consultationId = Long.parseLong(req.getParameter("id"));
            double coutTotal = generalisteService.calculerCoutTotal(consultationId);
            req.setAttribute("coutTotal", coutTotal);
            req.getRequestDispatcher("/WEB-INF/views/generaliste/detail_consultation.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();
        Utilisateur user = (Utilisateur) req.getSession().getAttribute("user");

        if ("/creer-consultation".equals(action)) {
            Long patientId = Long.parseLong(req.getParameter("patientId"));
            String motif = req.getParameter("motif");
            String observations = req.getParameter("observations");

            Consultation c = generalisteService.creerConsultation(patientId, user.getId(), motif, observations);
            resp.sendRedirect(req.getContextPath() + "/generaliste/consultation?id=" + c.getId());

        } else if ("/cloturer-directe".equals(action)) {
            Long consultationId = Long.parseLong(req.getParameter("consultationId"));
            String diagnostic = req.getParameter("diagnostic");
            String traitement = req.getParameter("traitement");

            generalisteService.cloturerConsultationDirecte(consultationId, diagnostic, traitement);
            resp.sendRedirect(req.getContextPath() + "/generaliste/dashboard?msg=Consultation+terminee");

        } else if ("/envoyer-demande-expertise".equals(action)) {
            Long consultationId = Long.parseLong(req.getParameter("consultationId"));
            Long specialisteId = Long.parseLong(req.getParameter("specialisteId"));
            Long creneauId = Long.parseLong(req.getParameter("creneauId"));
            String question = req.getParameter("question");
            Priorite priorite = Priorite.valueOf(req.getParameter("priorite"));

            generalisteService.demanderExpertise(consultationId, specialisteId, creneauId, question, priorite);
            resp.sendRedirect(req.getContextPath() + "/generaliste/dashboard?msg=Demande+d+expertise+envoyee");

        } else if ("/ajouter-acte".equals(action)) {
            Long consultationId = Long.parseLong(req.getParameter("consultationId"));
            String nomActe = req.getParameter("nomActe");
            double tarifActe = Double.parseDouble(req.getParameter("tarifActe"));

            generalisteService.ajouterActeMedical(consultationId, new ActeMedical(nomActe, tarifActe));
            resp.sendRedirect(req.getContextPath() + "/generaliste/detail-consultation?id=" + consultationId);
        }
    }
}
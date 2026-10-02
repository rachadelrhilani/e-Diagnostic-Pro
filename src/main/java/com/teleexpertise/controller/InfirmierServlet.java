package com.teleexpertise.controller;

import com.teleexpertise.dao.PatientDao;
import com.teleexpertise.model.Patient;
import com.teleexpertise.model.SignesVitaux;
import com.teleexpertise.service.InfirmierService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@WebServlet("/infirmier/*")
public class InfirmierServlet extends HttpServlet {

    private InfirmierService infirmierService;

    @Override
    public void init() throws ServletException {
        PatientDao patientDao = new PatientDao();
        this.infirmierService = new InfirmierService(patientDao);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();

        if ("/dashboard".equals(path) || "/patients".equals(path)) {
            List<Patient> patientsDuJour = infirmierService.getPatientsDuJour();
            req.setAttribute("patients", patientsDuJour);
            req.getRequestDispatcher("/WEB-INF/views/infirmier/dashboard.jsp").forward(req, resp);
        } else if ("/recherche".equals(path)) {
            req.getRequestDispatcher("/WEB-INF/views/infirmier/recherche.jsp").forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/infirmier/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();

        if ("/rechercher-patient".equals(action)) {
            String nss = req.getParameter("nss");
            Optional<Patient> patientOpt = infirmierService.rechercherPatientParNss(nss);

            if (patientOpt.isPresent()) {
                req.setAttribute("patient", patientOpt.get());
                req.getRequestDispatcher("/WEB-INF/views/infirmier/form_signes_vitaux.jsp").forward(req, resp);
            } else {
                req.setAttribute("nssSaisi", nss);
                req.getRequestDispatcher("/WEB-INF/views/infirmier/form_nouveau_patient.jsp").forward(req, resp);
            }

        } else if ("/ajouter-signes".equals(action)) {
            Long patientId = Long.parseLong(req.getParameter("patientId"));
            SignesVitaux sv = extraireSignesVitaux(req);

            infirmierService.ajouterSignesVitaux(patientId, sv);
            resp.sendRedirect(req.getContextPath() + "/infirmier/dashboard?msg=Signes+vitaux+enregistres");

        } else if ("/creer-patient".equals(action)) {
            Patient p = new Patient();
            p.setNom(req.getParameter("nom"));
            p.setPrenom(req.getParameter("prenom"));
            p.setNumeroSecuriteSociale(req.getParameter("nss"));
            p.setMutuelle(req.getParameter("mutuelle"));
            p.setTelephone(req.getParameter("telephone"));
            p.setAdresse(req.getParameter("adresse"));
            if (req.getParameter("dateNaissance") != null && !req.getParameter("dateNaissance").isEmpty()) {
                p.setDateNaissance(LocalDate.parse(req.getParameter("dateNaissance")));
            }

            SignesVitaux sv = extraireSignesVitaux(req);
            infirmierService.enregistrerNouveauPatient(p, sv);

            resp.sendRedirect(req.getContextPath() + "/infirmier/dashboard?msg=Patient+cree+et+ajoute+a+la+file");
        }
    }

    private SignesVitaux extraireSignesVitaux(HttpServletRequest req) {
        SignesVitaux sv = new SignesVitaux();
        sv.setTensionArterielle(req.getParameter("tension"));
        if (req.getParameter("frequenceCardiaque") != null) sv.setFrequenceCardiaque(Integer.parseInt(req.getParameter("frequenceCardiaque")));
        if (req.getParameter("temperature") != null) sv.setTemperature(Double.parseDouble(req.getParameter("temperature")));
        if (req.getParameter("frequenceRespiratoire") != null) sv.setFrequenceRespiratoire(Integer.parseInt(req.getParameter("frequenceRespiratoire")));
        if (req.getParameter("poids") != null) sv.setPoids(Double.parseDouble(req.getParameter("poids")));
        if (req.getParameter("taille") != null) sv.setTaille(Double.parseDouble(req.getParameter("taille")));
        return sv;
    }
}
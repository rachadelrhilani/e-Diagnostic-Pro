package com.teleexpertise.controller;

import com.teleexpertise.dao.ConsultationDao;
import com.teleexpertise.dao.PatientDao;
import com.teleexpertise.dao.UtilisateurDao;
import com.teleexpertise.model.Generaliste;
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
        ConsultationDao consultationDao = new ConsultationDao();
        UtilisateurDao utilisateurDao = new UtilisateurDao();
        this.infirmierService = new InfirmierService(patientDao, consultationDao, utilisateurDao);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();

        if (path == null || "/dashboard".equals(path) || "/patients".equals(path)) {
            // 1. Récupération du paramètre "dateFiltre" envoyé depuis la page JSP
            String dateStr = req.getParameter("dateFiltre");

            LocalDate dateRecherche;
            if (dateStr != null && !dateStr.trim().isEmpty()) {
                dateRecherche = LocalDate.parse(dateStr.trim());
            } else {
                dateRecherche = LocalDate.now(); // Date du jour par défaut
            }

            // 2. Appel du service avec le filtrage Stream API et le tri par heure d'arrivée
            List<Patient> patientsFiltres = infirmierService.getPatientsParDate(dateRecherche);
            List<Generaliste> generalistes = infirmierService.getAllGeneralistes();
            // 3. Transmission des données et de la date sélectionnée à la JSP
            req.setAttribute("patients", patientsFiltres);
            req.setAttribute("dateSelectionnee", dateRecherche);
            req.setAttribute("listeGeneralistes", generalistes);
            req.setAttribute("generalistesOccupes", infirmierService.getIdsGeneralistesOccupes());

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
                Patient patient = patientOpt.get();
                req.setAttribute("patient", patient);
                // Si le patient a déjà une consultation EN_COURS ou EN_ATTENTE_AVIS, on l'affiche
                req.setAttribute("consultationActive", infirmierService.getConsultationActivePatient(patient.getId()));
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
        } else if ("/envoyer-file-dattente".equals(action)) {
            String patientIdStr = req.getParameter("patientId");
            String generalisteIdStr = req.getParameter("generalisteId");

            if (patientIdStr == null || patientIdStr.trim().isEmpty() ||
                    generalisteIdStr == null || generalisteIdStr.trim().isEmpty()) {
                resp.sendRedirect(
                        req.getContextPath() + "/infirmier/dashboard?error=Veuillez+selectionner+un+generaliste");
                return;
            }

            Long patientId = Long.parseLong(patientIdStr.trim());
            Long generalisteId = Long.parseLong(generalisteIdStr.trim());
            String motif = req.getParameter("motif");
            String observations = req.getParameter("observations");

            try {
                infirmierService.envoyerVersFileDattente(patientId, generalisteId, motif, observations);
                resp.sendRedirect(req.getContextPath() + "/infirmier/dashboard?msg=Patient+place+en+file+d+attente");
            } catch (IllegalStateException e) {
                // Redirection avec le message d'erreur si déjà en cours
                resp.sendRedirect(req.getContextPath() + "/infirmier/dashboard?error="
                        + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
        }
    }

    private SignesVitaux extraireSignesVitaux(HttpServletRequest req) {
        SignesVitaux sv = new SignesVitaux();
        sv.setTensionArterielle(req.getParameter("tension"));
        if (req.getParameter("frequenceCardiaque") != null)
            sv.setFrequenceCardiaque(Integer.parseInt(req.getParameter("frequenceCardiaque")));
        if (req.getParameter("temperature") != null)
            sv.setTemperature(Double.parseDouble(req.getParameter("temperature")));
        if (req.getParameter("frequenceRespiratoire") != null)
            sv.setFrequenceRespiratoire(Integer.parseInt(req.getParameter("frequenceRespiratoire")));
        if (req.getParameter("poids") != null)
            sv.setPoids(Double.parseDouble(req.getParameter("poids")));
        if (req.getParameter("taille") != null)
            sv.setTaille(Double.parseDouble(req.getParameter("taille")));
        return sv;
    }
}
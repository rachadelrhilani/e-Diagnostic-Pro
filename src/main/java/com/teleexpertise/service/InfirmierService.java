package com.teleexpertise.service;

import com.teleexpertise.dao.ConsultationDao;
import com.teleexpertise.dao.PatientDao;
import com.teleexpertise.dao.UtilisateurDao;
import com.teleexpertise.model.Consultation;
import com.teleexpertise.model.Generaliste;
import com.teleexpertise.model.Patient;
import com.teleexpertise.model.SignesVitaux;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class InfirmierService {

    private final PatientDao patientDao;
    private final ConsultationDao consultationDao;
    private final UtilisateurDao utilisateurDao;

    public InfirmierService(PatientDao patientDao, ConsultationDao consultationDao, UtilisateurDao utilisateurDao) {
        this.patientDao = patientDao;
        this.consultationDao = consultationDao;
        this.utilisateurDao = utilisateurDao;
    }

    public Optional<Patient> rechercherPatientParNss(String nss) {
        return patientDao.findByNumeroSecuriteSociale(nss);
    }

    public SignesVitaux ajouterSignesVitaux(Long patientId, SignesVitaux signes) {
        return patientDao.addSignesVitaux(patientId, signes);
    }

    public List<Generaliste> getAllGeneralistes() {
        return utilisateurDao.findAllGeneralistes();
    }

    public Consultation envoyerVersFileDattente(Long patientId, Long generalisteId, String motif, String observations) {
        if (consultationDao.aUneConsultationEnCours(patientId)) {
            throw new IllegalStateException(
                    "Ce patient a déjà une consultation en cours ou est déjà dans la file d'attente.");
        }
        String motifAjuste = (motif != null && !motif.trim().isEmpty()) ? motif : "Orientation par l'infirmier(e)";
        String obsAjustees = (observations != null) ? observations : "Patient placé en file d'attente";

        // Appel direct à votre méthode DAO existante
        return consultationDao.creerConsultation(patientId, generalisteId, motifAjuste, obsAjustees);
    }

    public Patient enregistrerNouveauPatient(Patient patient, SignesVitaux signes) {
        return patientDao.enregistrerNouveauPatient(patient, signes);
    }

    public List<Patient> getPatientsParDate(LocalDate dateCible) {
    if (dateCible == null) {
        dateCible = LocalDate.now(); // Date par défaut si aucune n'est passée
    }

    final LocalDate dateAFiltrer = dateCible;
    List<Patient> tousLesPatients = patientDao.findAllWithSignesVitaux();

    List<Patient> patientsFiltres = tousLesPatients.stream()
            // 1. Filtrer les patients ayant au moins une prise de signes vitaux à la date cible
            .filter(p -> p.getSignesVitaux() != null && p.getSignesVitaux().stream()
                    .anyMatch(sv -> sv.getDatePrise() != null
                            && sv.getDatePrise().toLocalDate().equals(dateAFiltrer)))

            // 2. Trier par heure d'arrivée de cette journée (du plus ancien au plus récent)
            .sorted(Comparator.comparing(p -> p.getSignesVitaux().stream()
                    .map(SignesVitaux::getDatePrise)
                    .filter(date -> date != null && date.toLocalDate().equals(dateAFiltrer))
                    .min(Comparator.naturalOrder())
                    .orElse(null),
                    Comparator.nullsLast(Comparator.naturalOrder())))

            .collect(Collectors.toList());

    // 3. Calculer dynamiquement si chaque patient a déjà une consultation en cours
    for (Patient p : patientsFiltres) {
        p.setConsultationEnCours(consultationDao.aUneConsultationEnCours(p.getId()));
    }

    return patientsFiltres;
}

    /**
     * Conserve la méthode sans paramètre pour charger la liste d'aujourd'hui par
     * défaut
     */
    public List<Patient> getPatientsDuJour() {
        return getPatientsParDate(LocalDate.now());
    }
}
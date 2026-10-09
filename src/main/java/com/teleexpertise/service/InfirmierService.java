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
        // 1. Un patient ne peut avoir qu'une seule consultation active (EN_COURS ou EN_ATTENTE_AVIS)
        if (consultationDao.aUneConsultationEnCours(patientId)) {
            throw new IllegalStateException(
                    "Ce patient a déjà une consultation en cours ou est déjà dans la file d'attente.");
        }
        // 2. Un généraliste ne peut avoir qu'un seul patient EN_COURS à la fois
        List<Consultation> generalisteEnCours = consultationDao.findConsultationsEnCoursStrictParGeneraliste(generalisteId);
        if (generalisteEnCours != null && !generalisteEnCours.isEmpty()) {
            throw new IllegalStateException(
                    "Ce généraliste a déjà une consultation en cours (Dossier #" + generalisteEnCours.get(0).getId() +
                    " - " + generalisteEnCours.get(0).getPatient().getNom() + " " + generalisteEnCours.get(0).getPatient().getPrenom() +
                    "). Choisissez un autre médecin.");
        }
        String motifAjuste = (motif != null && !motif.trim().isEmpty()) ? motif : "Orientation par l'infirmier(e)";
        String obsAjustees = (observations != null) ? observations : "Patient placé en file d'attente";

        // Appel direct à votre méthode DAO existante
        return consultationDao.creerConsultation(patientId, generalisteId, motifAjuste, obsAjustees);
    }

    /**
     * Retourne la consultation active du patient (EN_COURS ou EN_ATTENTE), ou null.
     * Utilisé lors de la recherche NSS pour afficher que le patient est déjà en cours.
     */
    public Consultation getConsultationActivePatient(Long patientId) {
        if (patientId == null) return null;
        return consultationDao.findConsultationActiveParPatient(patientId);
    }

    /**
     * Vrai si le généraliste a déjà une consultation EN_COURS (EN_ATTENTE ne bloque pas).
     */
    public boolean generalisteAUneConsultationEnCours(Long generalisteId) {
        if (generalisteId == null) return false;
        List<Consultation> list = consultationDao.findConsultationsEnCoursStrictParGeneraliste(generalisteId);
        return list != null && !list.isEmpty();
    }

    /**
     * Ids des généralistes occupés (avec EN_COURS) pour griser la liste dans le dashboard infirmier.
     */
    public List<Long> getIdsGeneralistesOccupes() {
        return getAllGeneralistes().stream()
                .map(Generaliste::getId)
                .filter(this::generalisteAUneConsultationEnCours)
                .collect(Collectors.toList());
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
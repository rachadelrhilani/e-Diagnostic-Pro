package com.teleexpertise.service;

import com.teleexpertise.dao.ConsultationDao;
import com.teleexpertise.dao.CreneauDao;
import com.teleexpertise.dao.DemandeExpertiseDao;
import com.teleexpertise.dao.PatientDao;
import com.teleexpertise.dao.SpecialisteDao;
import com.teleexpertise.model.*;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class GeneralisteService {

    private final ConsultationDao consultationDao;
    private final SpecialisteDao specialisteDao;
    private final CreneauDao creneauDao;
    private final DemandeExpertiseDao demandeExpertiseDao;
    private final PatientDao patientDao;

    public GeneralisteService(ConsultationDao consultationDao, SpecialisteDao specialisteDao,
            CreneauDao creneauDao, DemandeExpertiseDao demandeExpertiseDao,PatientDao patientDao) {
        this.consultationDao = consultationDao;
        this.specialisteDao = specialisteDao;
        this.creneauDao = creneauDao;
        this.demandeExpertiseDao = demandeExpertiseDao;
        this.patientDao =patientDao;
    }

    public Consultation creerConsultation(Long patientId, Long generalisteId, String motif, String observations) {
        // Règle métier : un généraliste ne peut avoir qu'une seule consultation EN_COURS à la fois.
        // Une consultation EN_ATTENTE_AVIS_SPECIALISTE ne bloque pas la création.
        List<Consultation> consultationsEnCours = consultationDao.findConsultationsEnCoursStrictParGeneraliste(generalisteId);
        if (!consultationsEnCours.isEmpty()) {
            throw new IllegalStateException(
                "Vous avez déjà une consultation en cours (Dossier #" + consultationsEnCours.get(0).getId() +
                "). Veuillez la clôturer avant d'en démarrer une nouvelle.");
        }
        return consultationDao.creerConsultation(patientId, generalisteId, motif, observations);
    }

    public void cloturerConsultationDirecte(Long consultationId, String diagnostic, String traitement) {
        consultationDao.cloturerConsultationDirecte(consultationId, diagnostic, traitement);
    }

    public List<Specialiste> rechercherEtTrierSpecialistes(String specialite, Double maxTarif) {
        List<Specialiste> liste = specialisteDao.findBySpecialite(specialite);

        return liste.stream()
                .filter(s -> maxTarif == null || s.getTarif() <= maxTarif)
                .sorted(Comparator.comparingDouble(Specialiste::getTarif))
                .collect(Collectors.toList());
    }

    public List<Creneau> getCreneauxDisponibles(Long specialisteId) {
        return creneauDao.findFutursDisponiblesBySpecialisteId(specialisteId);
    }

    public DemandeExpertise demanderExpertise(Long consultationId, Long specialisteId, Long creneauId, String question,
            Priorite priorite) {
        return demandeExpertiseDao.envoyerDemandeExpertise(consultationId, specialisteId, creneauId, question,
                priorite);
    }

    public ActeMedical ajouterActeMedical(Long consultationId, ActeMedical acte) {
        return consultationDao.addActeMedical(consultationId, acte);
    }

    public double calculerCoutTotal(Long consultationId) {
        Consultation consultation = consultationDao.findConsultationComplete(consultationId);
        if (consultation == null)
            return 0.0;

        double coutBase = consultation.getCoutBase();

        double totalActes = consultation.getActesMedicaux().stream()
                .mapToDouble(ActeMedical::getTarif)
                .sum();

        double tarifExpertise = 0.0;
        if (consultation.getDemandeExpertise() != null && consultation.getDemandeExpertise().getSpecialiste() != null) {
            tarifExpertise = consultation.getDemandeExpertise().getSpecialiste().getTarif();
        }

        return coutBase + totalActes + tarifExpertise;
    }

    public List<Consultation> getConsultationsEnCoursParGeneraliste(Long generalisteId) {
        if (generalisteId == null) {
            return List.of();
        }
        return consultationDao.findConsultationsEnCoursParGeneraliste(generalisteId);
    }

    /**
     * Retourne uniquement les consultations EN_COURS (exclut EN_ATTENTE_AVIS_SPECIALISTE).
     * Utilisé pour la page recherche spécialiste : seuls ces dossiers peuvent faire l'objet
     * d'une nouvelle demande d'expertise.
     */
    public List<Consultation> getConsultationsEnCoursStrictParGeneraliste(Long generalisteId) {
        if (generalisteId == null) {
            return List.of();
        }
        return consultationDao.findConsultationsEnCoursStrictParGeneraliste(generalisteId);
    }

    public List<Patient> getPatientsEnAttente() {
        return patientDao.findPatientsEnAttente();
    }

    public List<Patient> getAllPatients() {
        return patientDao.findAllWithSignesVitaux();
    }

    public Consultation getConsultationComplete(Long consultationId) {
        if (consultationId == null) return null;
        return consultationDao.findConsultationComplete(consultationId);
    }

    public Specialiste getSpecialiste(Long specialisteId) {
        if (specialisteId == null) return null;
        return specialisteDao.findById(specialisteId).orElse(null);
    }

    public List<String> getSpecialitesDisponibles() {
        return specialisteDao.findDistinctSpecialites();
    }

    public double calculerTotalActes(Consultation consultation) {
        if (consultation == null || consultation.getActesMedicaux() == null) {
            return 0.0;
        }
        return consultation.getActesMedicaux().stream()
                .mapToDouble(ActeMedical::getTarif)
                .sum();
    }
}
package com.teleexpertise.service;

import com.teleexpertise.dao.ConsultationDao;
import com.teleexpertise.dao.CreneauDao;
import com.teleexpertise.dao.DemandeExpertiseDao;
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

    public GeneralisteService(ConsultationDao consultationDao, SpecialisteDao specialisteDao,
                             CreneauDao creneauDao, DemandeExpertiseDao demandeExpertiseDao) {
        this.consultationDao = consultationDao;
        this.specialisteDao = specialisteDao;
        this.creneauDao = creneauDao;
        this.demandeExpertiseDao = demandeExpertiseDao;
    }

    public Consultation creerConsultation(Long patientId, Long generalisteId, String motif, String observations) {
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

    
    public DemandeExpertise demanderExpertise(Long consultationId, Long specialisteId, Long creneauId, String question, Priorite priorite) {
        return demandeExpertiseDao.envoyerDemandeExpertise(consultationId, specialisteId, creneauId, question, priorite);
    }


    public ActeMedical ajouterActeMedical(Long consultationId, ActeMedical acte) {
        return consultationDao.addActeMedical(consultationId, acte);
    }

    public double calculerCoutTotal(Long consultationId) {
        Consultation consultation = consultationDao.findConsultationComplete(consultationId);
        if (consultation == null) return 0.0;

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
}
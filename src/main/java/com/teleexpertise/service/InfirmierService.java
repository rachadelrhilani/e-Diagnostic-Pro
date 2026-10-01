package com.teleexpertise.service;

import com.teleexpertise.dao.PatientDao;
import com.teleexpertise.model.Patient;
import com.teleexpertise.model.SignesVitaux;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class InfirmierService {

    private final PatientDao patientDao;

    public InfirmierService(PatientDao patientDao) {
        this.patientDao = patientDao;
    }

   
    public Optional<Patient> rechercherPatientParNss(String nss) {
        return patientDao.findByNumeroSecuriteSociale(nss);
    }

    
    public SignesVitaux ajouterSignesVitaux(Long patientId, SignesVitaux signes) {
        return patientDao.addSignesVitaux(patientId, signes);
    }

    
    public Patient enregistrerNouveauPatient(Patient patient, SignesVitaux signes) {
        return patientDao.enregistrerNouveauPatient(patient, signes);
    }

    public List<Patient> getPatientsDuJour() {
        LocalDate aujourdhui = LocalDate.now();
        List<Patient> tousLesPatients = patientDao.findAllWithSignesVitaux();

        return tousLesPatients.stream()
                .filter(p -> p.getSignesVitaux().stream()
                        .anyMatch(sv -> sv.getDatePrise().toLocalDate().equals(aujourdhui)))
                .sorted(Comparator.comparing(p -> p.getSignesVitaux().stream()
                        .map(SignesVitaux::getDatePrise)
                        .min(Comparator.naturalOrder())
                        .orElse(null), Comparator.nullsLast(Comparator.naturalOrder())))
                .collect(Collectors.toList());
    }
}
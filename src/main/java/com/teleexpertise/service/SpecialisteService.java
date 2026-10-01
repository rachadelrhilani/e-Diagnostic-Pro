package com.teleexpertise.service;

import com.teleexpertise.dao.CreneauDao;
import com.teleexpertise.dao.DemandeExpertiseDao;
import com.teleexpertise.dao.UtilisateurDao;
import com.teleexpertise.model.*;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class SpecialisteService {

    private final UtilisateurDao utilisateurDao;
    private final CreneauDao creneauDao;
    private final DemandeExpertiseDao demandeExpertiseDao;

    public SpecialisteService() {
        this.utilisateurDao = new UtilisateurDao();
        this.creneauDao = new CreneauDao();
        this.demandeExpertiseDao = new DemandeExpertiseDao();
    }

    public SpecialisteService(UtilisateurDao utilisateurDao, CreneauDao creneauDao, DemandeExpertiseDao demandeExpertiseDao) {
        this.utilisateurDao = utilisateurDao;
        this.creneauDao = creneauDao;
        this.demandeExpertiseDao = demandeExpertiseDao;
    }

    
    public void configurerProfil(Long specialisteId, String specialite, double tarif) {
        utilisateurDao.updateProfilSpecialiste(specialisteId, specialite, tarif);
    }

    
    public List<Creneau> consulterCreneaux(Long specialisteId) {
        creneauDao.archiverCreneauxPasses();
        return creneauDao.findBySpecialisteId(specialisteId);
    }

   
    public List<DemandeExpertise> consulterDemandesFiltrees(Long specialisteId, StatutExpertise statut, Priorite priorite) {
        List<DemandeExpertise> demandes = demandeExpertiseDao.findBySpecialisteId(specialisteId);

        return demandes.stream()
                .filter(d -> statut == null || d.getStatut() == statut)
                .filter(d -> priorite == null || d.getPriorite() == priorite)
                .sorted(Comparator.comparing(DemandeExpertise::getDateDemande).reversed())
                .collect(Collectors.toList());
    }

    
    public void repondreAExpertise(Long demandeId, String avisMedical, String recommandations) {
        demandeExpertiseDao.repondreAExpertise(demandeId, avisMedical, recommandations);
    }
}
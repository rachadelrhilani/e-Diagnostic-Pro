package com.teleexpertise.service;

import com.teleexpertise.dao.CreneauDao;
import com.teleexpertise.dao.DemandeExpertiseDao;
import com.teleexpertise.dao.SpecialisteDao;
import com.teleexpertise.dao.UtilisateurDao;
import com.teleexpertise.dto.CreneauHoraireDTO;
import com.teleexpertise.model.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class SpecialisteService {

    private final UtilisateurDao utilisateurDao;
    private final CreneauDao creneauDao;
    private final DemandeExpertiseDao demandeExpertiseDao;
    private final SpecialisteDao specialisteDao;

    // Plages horaires de consultation standard (tranches fixes de 30 minutes)
    public static final List<LocalTime> PLAGES_HORAIRES = List.of(
        LocalTime.of(8, 0), LocalTime.of(8, 30),
        LocalTime.of(9, 0), LocalTime.of(9, 30),
        LocalTime.of(10, 0), LocalTime.of(10, 30),
        LocalTime.of(11, 0), LocalTime.of(11, 30),
        LocalTime.of(14, 0), LocalTime.of(14, 30),
        LocalTime.of(15, 0), LocalTime.of(15, 30),
        LocalTime.of(16, 0), LocalTime.of(16, 30),
        LocalTime.of(17, 0), LocalTime.of(17, 30)
    );

    public SpecialisteService() {
        this.utilisateurDao = new UtilisateurDao();
        this.creneauDao = new CreneauDao();
        this.demandeExpertiseDao = new DemandeExpertiseDao();
        this.specialisteDao = new SpecialisteDao();
    }

    public SpecialisteService(UtilisateurDao utilisateurDao, CreneauDao creneauDao, DemandeExpertiseDao demandeExpertiseDao) {
        this.utilisateurDao = utilisateurDao;
        this.creneauDao = creneauDao;
        this.demandeExpertiseDao = demandeExpertiseDao;
        this.specialisteDao = new SpecialisteDao();
    }

    public SpecialisteService(UtilisateurDao utilisateurDao, CreneauDao creneauDao, DemandeExpertiseDao demandeExpertiseDao, SpecialisteDao specialisteDao) {
        this.utilisateurDao = utilisateurDao;
        this.creneauDao = creneauDao;
        this.demandeExpertiseDao = demandeExpertiseDao;
        this.specialisteDao = specialisteDao;
    }

    /**
     * US5: Configurer son profil (tarif, spécialité, durée moyenne fixe 30 min)
     */
    public void configurerProfil(Long specialisteId, String specialite, double tarif) {
        utilisateurDao.updateProfilSpecialiste(specialisteId, specialite, tarif);
    }

    public Specialiste getSpecialiste(Long specialisteId) {
        if (specialisteId == null) return null;
        return specialisteDao.findById(specialisteId).orElse(null);
    }

    /**
     * US6: Consulter les créneaux avec archivage automatique des créneaux passés
     */
    public List<Creneau> consulterCreneaux(Long specialisteId) {
        creneauDao.archiverCreneauxPasses();
        return creneauDao.findBySpecialisteId(specialisteId);
    }

    /**
     * US6: Récupérer la grille des disponibilités pour une date donnée.
     * Règle métier : les créneaux passés selon la date et l'heure actuelle sont marqués DÉSACTIVÉS (passe=true).
     */
    public List<CreneauHoraireDTO> getGrilleDisponibilites(Long specialisteId, LocalDate date) {
        if (date == null) {
            date = LocalDate.now();
        }

        // Mettre à jour l'archivage automatique
        creneauDao.archiverCreneauxPasses();

        List<Creneau> creneauxExistants = creneauDao.findBySpecialisteIdAndDate(specialisteId, date);
        LocalDateTime now = LocalDateTime.now();

        List<CreneauHoraireDTO> grille = new ArrayList<>();
        for (LocalTime heure : PLAGES_HORAIRES) {
            LocalDateTime debut = LocalDateTime.of(date, heure);
            LocalTime fin = heure.plusMinutes(30);

            // Règle métier : désactivé si l'heure est passée par rapport au moment actuel
            boolean passe = debut.isBefore(now);

            // Vérifier si un créneau existe déjà pour ce spécialiste à cette heure
            Creneau existant = creneauxExistants.stream()
                .filter(c -> c.getHeureDebut().toLocalTime().equals(heure))
                .findFirst()
                .orElse(null);

            boolean dejaExistant = (existant != null);

            grille.add(new CreneauHoraireDTO(heure, fin, passe, dejaExistant, existant));
        }
        return grille;
    }

    /**
     * US6: Créer de nouvelles disponibilités sélectionnées par le spécialiste.
     * Règle stricte : les créneaux dont l'heure de début est passée sont ignorés/rejetés.
     */
    public int creerDisponibilites(Long specialisteId, LocalDate date, List<LocalTime> heuresSelectionnees) {
        if (date == null || heuresSelectionnees == null || heuresSelectionnees.isEmpty()) {
            return 0;
        }
        if (date.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException("Impossible de créer des disponibilités pour une date passée.");
        }

        LocalDateTime now = LocalDateTime.now();
        int count = 0;

        for (LocalTime heure : heuresSelectionnees) {
            LocalDateTime debut = LocalDateTime.of(date, heure);
            // Ignorer si l'heure est passée
            if (debut.isBefore(now)) {
                continue;
            }
            if (!creneauDao.existeCreneau(specialisteId, debut)) {
                creneauDao.creerCreneau(specialisteId, debut, debut.plusMinutes(30));
                count++;
            }
        }
        return count;
    }

    /**
     * US6: Supprimer un créneau encore disponible
     */
    public boolean supprimerCreneau(Long creneauId, Long specialisteId) {
        return creneauDao.supprimerCreneau(creneauId, specialisteId);
    }

    /**
     * US6: Annuler une expertise : le créneau redevient automatiquement disponible
     */
    public void annulerDemandeExpertise(Long demandeId) {
        demandeExpertiseDao.annulerDemandeExpertise(demandeId);
    }

    /**
     * US7: Consulter les demandes reçues filtrées via Stream API
     */
    public List<DemandeExpertise> consulterDemandesFiltrees(Long specialisteId, StatutExpertise statut, Priorite priorite) {
        List<DemandeExpertise> demandes = demandeExpertiseDao.findBySpecialisteId(specialisteId);

        return demandes.stream()
                .filter(d -> statut == null || d.getStatut() == statut)
                .filter(d -> priorite == null || d.getPriorite() == priorite)
                .sorted(Comparator.comparing(DemandeExpertise::getDateDemande).reversed())
                .collect(Collectors.toList());
    }

    /**
     * US7 / US8: Récupérer le dossier complet d'une demande pour examiner le patient et la question
     */
    public DemandeExpertise getDemandeComplete(Long demandeId) {
        return demandeExpertiseDao.findDemandeComplete(demandeId);
    }

    /**
     * US8: Saisir l'avis médical, les recommandations et marquer comme terminée
     */
    public void repondreAExpertise(Long demandeId, String avisMedical, String recommandations) {
        demandeExpertiseDao.repondreAExpertise(demandeId, avisMedical, recommandations);
    }
}
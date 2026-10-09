package com.teleexpertise.dto;

import com.teleexpertise.model.Creneau;
import java.io.Serializable;
import java.time.LocalTime;

/**
 * DTO représentant une tranche horaire journalière pour la gestion des disponibilités
 * Permet de savoir si le créneau est passé (selon la date et l'heure actuelle) ou déjà existant.
 */
public class CreneauHoraireDTO implements Serializable {

    private LocalTime heureDebut;
    private LocalTime heureFin;
    private boolean passe;
    private boolean dejaExistant;
    private Creneau creneauExistant;

    public CreneauHoraireDTO() {}

    public CreneauHoraireDTO(LocalTime heureDebut, LocalTime heureFin, boolean passe, boolean dejaExistant, Creneau creneauExistant) {
        this.heureDebut = heureDebut;
        this.heureFin = heureFin;
        this.passe = passe;
        this.dejaExistant = dejaExistant;
        this.creneauExistant = creneauExistant;
    }

    public LocalTime getHeureDebut() {
        return heureDebut;
    }

    public void setHeureDebut(LocalTime heureDebut) {
        this.heureDebut = heureDebut;
    }

    public LocalTime getHeureFin() {
        return heureFin;
    }

    public void setHeureFin(LocalTime heureFin) {
        this.heureFin = heureFin;
    }

    public boolean isPasse() {
        return passe;
    }

    public void setPasse(boolean passe) {
        this.passe = passe;
    }

    public boolean isDejaExistant() {
        return dejaExistant;
    }

    public void setDejaExistant(boolean dejaExistant) {
        this.dejaExistant = dejaExistant;
    }

    public Creneau getCreneauExistant() {
        return creneauExistant;
    }

    public void setCreneauExistant(Creneau creneauExistant) {
        this.creneauExistant = creneauExistant;
    }

    public boolean isSelectionnable() {
        return !passe && !dejaExistant;
    }
}

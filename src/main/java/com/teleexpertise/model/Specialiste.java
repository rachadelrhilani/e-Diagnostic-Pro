package com.teleexpertise.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "specialistes")
public class Specialiste extends Utilisateur {

    @Column(nullable = false)
    private String specialite; // ex: Cardiologue, Pneumologue, etc.

    @Column(nullable = false)
    private double tarif; // Tarif de consultation / expertise

    @Column(nullable = false)
    private int dureeMoyenne = 30; // 30 minutes par défaut

    @OneToMany(mappedBy = "specialiste", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Creneau> creneaux = new ArrayList<>();

    @OneToMany(mappedBy = "specialiste")
    private List<DemandeExpertise> demandesExpertise = new ArrayList<>();

    public Specialiste() {
        super();
        setRole(Role.SPECIALISTE);
    }

    public Specialiste(String nom, String prenom, String email, String password, String specialite, double tarif) {
        super(nom, prenom, email, password, Role.SPECIALISTE);
        this.specialite = specialite;
        this.tarif = tarif;
    }

    // Getters et Setters
    public String getSpecialite() { return specialite; }
    public void setSpecialite(String specialite) { this.specialite = specialite; }

    public double getTarif() { return tarif; }
    public void setTarif(double tarif) { this.tarif = tarif; }

    public int getDureeMoyenne() { return dureeMoyenne; }
    public void setDureeMoyenne(int dureeMoyenne) { this.dureeMoyenne = dureeMoyenne; }

    public List<Creneau> getCreneaux() { return creneaux; }
    public void setCreneaux(List<Creneau> creneaux) { this.creneaux = creneaux; }

    public List<DemandeExpertise> getDemandesExpertise() { return demandesExpertise; }
    public void setDemandesExpertise(List<DemandeExpertise> demandesExpertise) { this.demandesExpertise = demandesExpertise; }
}
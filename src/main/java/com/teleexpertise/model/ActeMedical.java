package com.teleexpertise.model;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "actes_medicaux")
public class ActeMedical implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "nom", length = 150, nullable = false)
    private String nom; // Radiographie, IRM, Analyse de sang, etc.

    @Column(name = "tarif", nullable = false)
    private double tarif;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "consultation_id")
    private Consultation consultation;

    public ActeMedical() {}

    public ActeMedical(String nom, double tarif) {
        this.nom = nom;
        this.tarif = tarif;
    }

    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public double getTarif() { return tarif; }
    public void setTarif(double tarif) { this.tarif = tarif; }

    public Consultation getConsultation() { return consultation; }
    public void setConsultation(Consultation consultation) { this.consultation = consultation; }
}
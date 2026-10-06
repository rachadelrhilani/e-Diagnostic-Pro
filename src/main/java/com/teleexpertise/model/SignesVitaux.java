package com.teleexpertise.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "signes_vitaux")
public class SignesVitaux implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "tension_arterielle", length = 20)
    private String tensionArterielle;

    @Column(name = "frequence_cardiaque")
    private int frequenceCardiaque;

    @Column(name = "temperature")
    private double temperature;

    @Column(name = "frequence_respiratoire")
    private int frequenceRespiratoire;

    @Column(name = "poids")
    private Double poids;

    @Column(name = "taille")
    private Double taille;

    @Column(name = "date_prise", nullable = false)
    private LocalDateTime datePrise = LocalDateTime.now();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    public SignesVitaux() {}

    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTensionArterielle() { return tensionArterielle; }
    public void setTensionArterielle(String tensionArterielle) { this.tensionArterielle = tensionArterielle; }

    public int getFrequenceCardiaque() { return frequenceCardiaque; }
    public void setFrequenceCardiaque(int frequenceCardiaque) { this.frequenceCardiaque = frequenceCardiaque; }

    public double getTemperature() { return temperature; }
    public void setTemperature(double temperature) { this.temperature = temperature; }

    public int getFrequenceRespiratoire() { return frequenceRespiratoire; }
    public void setFrequenceRespiratoire(int frequenceRespiratoire) { this.frequenceRespiratoire = frequenceRespiratoire; }

    public Double getPoids() { return poids; }
    public void setPoids(Double poids) { this.poids = poids; }

    public Double getTaille() { return taille; }
    public void setTaille(Double taille) { this.taille = taille; }

    public LocalDateTime getDatePrise() { return datePrise; }
    public void setDatePrise(LocalDateTime datePrise) { this.datePrise = datePrise; }

    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }
}
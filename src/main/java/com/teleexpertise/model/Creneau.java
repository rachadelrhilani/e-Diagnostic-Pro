package com.teleexpertise.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "creneaux")
public class Creneau implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "heure_debut", nullable = false)
    private LocalDateTime heureDebut;

    @Column(name = "heure_fin", nullable = false)
    private LocalDateTime heureFin;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false)
    private StatutCreneau statut = StatutCreneau.DISPONIBLE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "specialiste_id", nullable = false)
    private Specialiste specialiste;

    public Creneau() {}

    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public LocalDateTime getHeureDebut() { return heureDebut; }
    public void setHeureDebut(LocalDateTime heureDebut) { this.heureDebut = heureDebut; }

    public LocalDateTime getHeureFin() { return heureFin; }
    public void setHeureFin(LocalDateTime heureFin) { this.heureFin = heureFin; }

    public StatutCreneau getStatut() { return statut; }
    public void setStatut(StatutCreneau statut) { this.statut = statut; }

    public Specialiste getSpecialiste() { return specialiste; }
    public void setSpecialiste(Specialiste specialiste) { this.specialiste = specialiste; }
}
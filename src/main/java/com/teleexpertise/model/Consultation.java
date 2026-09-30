package com.teleexpertise.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "consultations")
public class Consultation implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDateTime dateConsultation = LocalDateTime.now();

    @Column(columnDefinition = "TEXT")
    private String motif;

    @Column(columnDefinition = "TEXT")
    private String observations;

    @Column(columnDefinition = "TEXT")
    private String diagnostic;

    @Column(columnDefinition = "TEXT")
    private String traitement;

    @Column(nullable = false)
    private double coutBase = 150.0; // 150 DH fixe pour le généraliste

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutConsultation statut = StatutConsultation.EN_COURS;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "generaliste_id", nullable = false)
    private Generaliste generaliste;

    @OneToOne(mappedBy = "consultation", cascade = CascadeType.ALL, orphanRemoval = true)
    private DemandeExpertise demandeExpertise;

    @OneToMany(mappedBy = "consultation", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ActeMedical> actesMedicaux = new ArrayList<>();

    public Consultation() {}

    /**
     * Calcul du coût total à l'aide des expressions Lambda (map().sum())
     */
    public double getCoutTotal() {
        double totalActes = actesMedicaux.stream()
                .mapToDouble(ActeMedical::getTarif)
                .sum();

        double tarifExpertise = (demandeExpertise != null && demandeExpertise.getSpecialiste() != null)
                ? demandeExpertise.getSpecialiste().getTarif()
                : 0.0;

        return coutBase + tarifExpertise + totalActes;
    }

    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public LocalDateTime getDateConsultation() { return dateConsultation; }
    public void setDateConsultation(LocalDateTime dateConsultation) { this.dateConsultation = dateConsultation; }

    public String getMotif() { return motif; }
    public void setMotif(String motif) { this.motif = motif; }

    public String getObservations() { return observations; }
    public void setObservations(String observations) { this.observations = observations; }

    public String getDiagnostic() { return diagnostic; }
    public void setDiagnostic(String diagnostic) { this.diagnostic = diagnostic; }

    public String getTraitement() { return traitement; }
    public void setTraitement(String traitement) { this.traitement = traitement; }

    public double getCoutBase() { return coutBase; }
    public void setCoutBase(double coutBase) { this.coutBase = coutBase; }

    public StatutConsultation getStatut() { return statut; }
    public void setStatut(StatutConsultation statut) { this.statut = statut; }

    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }

    public Generaliste getGeneraliste() { return generaliste; }
    public void setGeneraliste(Generaliste generaliste) { this.generaliste = generaliste; }

    public DemandeExpertise getDemandeExpertise() { return demandeExpertise; }
    public void setDemandeExpertise(DemandeExpertise demandeExpertise) { this.demandeExpertise = demandeExpertise; }

    public List<ActeMedical> getActesMedicaux() { return actesMedicaux; }
    public void setActesMedicaux(List<ActeMedical> actesMedicaux) { this.actesMedicaux = actesMedicaux; }
}
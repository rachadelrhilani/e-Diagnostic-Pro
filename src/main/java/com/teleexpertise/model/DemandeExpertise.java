package com.teleexpertise.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "demandes_expertise")
public class DemandeExpertise implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "question", columnDefinition = "TEXT", nullable = false)
    private String question;

    @Enumerated(EnumType.STRING)
    @Column(name = "priorite", nullable = false)
    private Priorite priorite;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false)
    private StatutExpertise statut = StatutExpertise.EN_ATTENTE;

    @Column(name = "avis_medical", columnDefinition = "TEXT")
    private String avisMedical; // Réponse du spécialiste

    @Column(name = "recommandations", columnDefinition = "TEXT")
    private String recommandations; // Recommandations du spécialiste

    @Column(name = "date_demande", nullable = false)
    private LocalDateTime dateDemande = LocalDateTime.now();

    @Column(name = "date_reponse")
    private LocalDateTime dateReponse;

    @OneToOne
    @JoinColumn(name = "consultation_id", nullable = false, unique = true)
    private Consultation consultation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "specialiste_id", nullable = false)
    private Specialiste specialiste;

    @OneToOne
    @JoinColumn(name = "creneau_id", unique = true)
    private Creneau creneau;

    public DemandeExpertise() {}

    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public Priorite getPriorite() { return priorite; }
    public void setPriorite(Priorite priorite) { this.priorite = priorite; }

    public StatutExpertise getStatut() { return statut; }
    public void setStatut(StatutExpertise statut) { this.statut = statut; }

    public String getAvisMedical() { return avisMedical; }
    public void setAvisMedical(String avisMedical) { this.avisMedical = avisMedical; }

    public String getRecommandations() { return recommandations; }
    public void setRecommandations(String recommandations) { this.recommandations = recommandations; }

    public LocalDateTime getDateDemande() { return dateDemande; }
    public void setDateDemande(LocalDateTime dateDemande) { this.dateDemande = dateDemande; }

    public LocalDateTime getDateReponse() { return dateReponse; }
    public void setDateReponse(LocalDateTime dateReponse) { this.dateReponse = dateReponse; }

    public Consultation getConsultation() { return consultation; }
    public void setConsultation(Consultation consultation) { this.consultation = consultation; }

    public Specialiste getSpecialiste() { return specialiste; }
    public void setSpecialiste(Specialiste specialiste) { this.specialiste = specialiste; }

    public Creneau getCreneau() { return creneau; }
    public void setCreneau(Creneau creneau) { this.creneau = creneau; }
}
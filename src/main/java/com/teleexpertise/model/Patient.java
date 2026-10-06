package com.teleexpertise.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "patients")
public class Patient implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "nom", length = 100, nullable = false)
    private String nom;

    @Column(name = "prenom", length = 100, nullable = false)
    private String prenom;

    @Column(name = "date_naissance")
    private LocalDate dateNaissance;

    @Column(name = "numero_securite_sociale", length = 50, nullable = false, unique = true)
    private String numeroSecuriteSociale;

    @Column(name = "mutuelle", length = 100)
    private String mutuelle;

    @Column(name = "telephone", length = 30)
    private String telephone;

    @Column(name = "adresse", columnDefinition = "TEXT")
    private String adresse;

    @Column(name = "antecedents", columnDefinition = "TEXT")
    private String antecedents;

    @Column(name = "allergies", columnDefinition = "TEXT")
    private String allergies;

    @Column(name = "traitements_en_cours", columnDefinition = "TEXT")
    private String traitementsEnCours;

    @OneToMany(mappedBy = "patient", cascade = CascadeType.ALL)
    private List<SignesVitaux> signesVitaux = new ArrayList<>();

    @OneToMany(mappedBy = "patient", cascade = CascadeType.ALL)
    private List<Consultation> consultations = new ArrayList<>();

    public Patient() {}

    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public LocalDate getDateNaissance() { return dateNaissance; }
    public void setDateNaissance(LocalDate dateNaissance) { this.dateNaissance = dateNaissance; }

    public String getNumeroSecuriteSociale() { return numeroSecuriteSociale; }
    public void setNumeroSecuriteSociale(String numeroSecuriteSociale) { this.numeroSecuriteSociale = numeroSecuriteSociale; }

    public String getMutuelle() { return mutuelle; }
    public void setMutuelle(String mutuelle) { this.mutuelle = mutuelle; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public String getAntecedents() { return antecedents; }
    public void setAntecedents(String antecedents) { this.antecedents = antecedents; }

    public String getAllergies() { return allergies; }
    public void setAllergies(String allergies) { this.allergies = allergies; }

    public String getTraitementsEnCours() { return traitementsEnCours; }
    public void setTraitementsEnCours(String traitementsEnCours) { this.traitementsEnCours = traitementsEnCours; }

    public List<SignesVitaux> getSignesVitaux() { return signesVitaux; }
    public void setSignesVitaux(List<SignesVitaux> signesVitaux) { this.signesVitaux = signesVitaux; }

    public List<Consultation> getConsultations() { return consultations; }
    public void setConsultations(List<Consultation> consultations) { this.consultations = consultations; }
}
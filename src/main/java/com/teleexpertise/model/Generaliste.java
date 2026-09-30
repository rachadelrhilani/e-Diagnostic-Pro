package com.teleexpertise.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "generalistes")
public class Generaliste extends Utilisateur {

    @OneToMany(mappedBy = "generaliste", cascade = CascadeType.ALL)
    private List<Consultation> consultations = new ArrayList<>();

    public Generaliste() {
        super();
        setRole(Role.GENERALISTE);
    }

    public Generaliste(String nom, String prenom, String email, String password) {
        super(nom, prenom, email, password, Role.GENERALISTE);
    }

    public List<Consultation> getConsultations() { return consultations; }
    public void setConsultations(List<Consultation> consultations) { this.consultations = consultations; }
}
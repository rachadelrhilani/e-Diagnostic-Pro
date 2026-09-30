package com.teleexpertise.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "infirmiers")
public class Infirmier extends Utilisateur {

    public Infirmier() {
        super();
        setRole(Role.INFIRMIER);
    }

    public Infirmier(String nom, String prenom, String email, String password) {
        super(nom, prenom, email, password, Role.INFIRMIER);
    }
}
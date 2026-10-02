package com.teleexpertise.service;

import com.teleexpertise.dao.UtilisateurDao;
import com.teleexpertise.model.Utilisateur;
import com.teleexpertise.util.PasswordUtil;

import java.util.Optional;

public class AuthService {

    private final UtilisateurDao utilisateurDao;

    public AuthService() {
        this.utilisateurDao = new UtilisateurDao();
    }

    public AuthService(UtilisateurDao utilisateurDao) {
        this.utilisateurDao = utilisateurDao;
    }


    public Optional<Utilisateur> login(String email, String rawPassword) {
        Optional<Utilisateur> userOpt = utilisateurDao.findByEmail(email);

        if (userOpt.isPresent()) {
            Utilisateur user = userOpt.get();
            if (PasswordUtil.verifyPassword(rawPassword, user.getPassword())) {
                return Optional.of(user);
            }
        }
        return Optional.empty();
    }

   
    public Utilisateur registerUser(Utilisateur user, String rawPassword) {
        String hashedPassword = PasswordUtil.hashPassword(rawPassword);
        user.setPassword(hashedPassword);
        return utilisateurDao.save(user);
    }
}
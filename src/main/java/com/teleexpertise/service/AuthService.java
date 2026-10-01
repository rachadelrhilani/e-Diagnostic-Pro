package com.teleexpertise.service;

import at.favre.lib.crypto.bcrypt.BCrypt;
import com.teleexpertise.dao.UtilisateurDao;
import com.teleexpertise.model.Utilisateur;

import java.util.Optional;

public class AuthService {

    private final UtilisateurDao utilisateurDao;

    
    public AuthService(UtilisateurDao utilisateurDao) {
        this.utilisateurDao = utilisateurDao;
    }

    
    public Optional<Utilisateur> login(String email, String rawPassword) {
        Optional<Utilisateur> userOpt = utilisateurDao.findByEmail(email);

        if (userOpt.isPresent()) {
            Utilisateur user = userOpt.get();
            BCrypt.Result result = BCrypt.verifyer().verify(rawPassword.toCharArray(), user.getPassword());
            if (result.verified) {
                return Optional.of(user);
            }
        }
        return Optional.empty();
    }

    
    public Utilisateur registerUser(Utilisateur user, String rawPassword) {
        String hashedPassword = BCrypt.withDefaults().hashToString(12, rawPassword.toCharArray());
        user.setPassword(hashedPassword);
        return utilisateurDao.save(user);
    }
}
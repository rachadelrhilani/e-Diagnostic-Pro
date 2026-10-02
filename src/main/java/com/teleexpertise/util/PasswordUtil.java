package com.teleexpertise.util;

import at.favre.lib.crypto.bcrypt.BCrypt;

public class PasswordUtil {

    // Facteur de coût (work factor) pour BCrypt (12 est le standard recommandé)
    private static final int BCRYPT_COST = 12;

   
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Le mot de passe ne peut pas être vide.");
        }
        return BCrypt.withDefaults().hashToString(BCRYPT_COST, plainPassword.toCharArray());
    }

     
     
    public static boolean verifyPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        BCrypt.Result result = BCrypt.verifyer().verify(plainPassword.toCharArray(), hashedPassword);
        return result.verified;
    }
}
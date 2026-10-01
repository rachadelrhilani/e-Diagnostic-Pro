package com.teleexpertise.dao;

import com.teleexpertise.model.Specialiste;
import com.teleexpertise.model.Utilisateur;
import com.teleexpertise.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;

import java.util.Optional;

public class UtilisateurDao extends GenericDaoImpl<Utilisateur, Long> {

    public UtilisateurDao() {
        super(Utilisateur.class);
    }

    /**
     * Module Authentification: Login
     */
    public Optional<Utilisateur> findByEmail(String email) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Utilisateur user = em.createQuery(
                "SELECT u FROM Utilisateur u WHERE u.email = :email", Utilisateur.class)
                .setParameter("email", email)
                .getSingleResult();
            return Optional.of(user);
        } catch (NoResultException e) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    /**
     * US5: Configurer le profil du médecin spécialiste (tarif, spécialité)
     */
    public void updateProfilSpecialiste(Long specialisteId, String specialite, double tarif) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Specialiste sp = em.find(Specialiste.class, specialisteId);
            if (sp != null) {
                sp.setSpecialite(specialite);
                sp.setTarif(tarif);
                em.merge(sp);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
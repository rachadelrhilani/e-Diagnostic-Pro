package com.teleexpertise.dao;

import com.teleexpertise.model.Specialiste;
import com.teleexpertise.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.util.List;

public class SpecialisteDao extends GenericDaoImpl<Specialiste, Long> {

    public SpecialisteDao() {
        super(Specialiste.class);
    }

    /**
     * US3: Récupérer tous les spécialistes d'une spécialité donnée
     */
    public List<Specialiste> findBySpecialite(String specialite) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT s FROM Specialiste s WHERE LOWER(s.specialite) = LOWER(:specialite)", Specialiste.class)
                .setParameter("specialite", specialite)
                .getResultList();
        } finally {
            em.close();
        }
    }
}
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
            if (specialite == null || specialite.trim().isEmpty() || "ALL".equalsIgnoreCase(specialite.trim()) || "TOUTES".equalsIgnoreCase(specialite.trim())) {
                return em.createQuery("SELECT s FROM Specialiste s", Specialiste.class).getResultList();
            }
            return em.createQuery(
                "SELECT s FROM Specialiste s WHERE LOWER(s.specialite) LIKE LOWER(:specialite)", Specialiste.class)
                .setParameter("specialite", "%" + specialite.trim() + "%")
                .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Récupérer la liste de toutes les spécialités distinctes existantes
     */
    public List<String> findDistinctSpecialites() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT DISTINCT s.specialite FROM Specialiste s WHERE s.specialite IS NOT NULL AND TRIM(s.specialite) != '' ORDER BY s.specialite ASC", String.class)
                .getResultList();
        } finally {
            em.close();
        }
    }
}
package com.teleexpertise.dao;

import com.teleexpertise.model.Creneau;
import com.teleexpertise.model.StatutCreneau;
import com.teleexpertise.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

import java.time.LocalDateTime;
import java.util.List;

public class CreneauDao extends GenericDaoImpl<Creneau, Long> {

    public CreneauDao() {
        super(Creneau.class);
    }

    /**
     * US6: Récupérer les créneaux d'un spécialiste
     */
    public List<Creneau> findBySpecialisteId(Long specialisteId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT c FROM Creneau c WHERE c.specialiste.id = :specialisteId ORDER BY c.heureDebut ASC", Creneau.class)
                .setParameter("specialisteId", specialisteId)
                .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * US3: Récupérer uniquement les créneaux futurs disponibles d'un spécialiste
     */
    public List<Creneau> findFutursDisponiblesBySpecialisteId(Long specialisteId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT c FROM Creneau c WHERE c.specialiste.id = :specialisteId " +
                "AND c.heureDebut > :now AND c.statut = :dispo ORDER BY c.heureDebut ASC", Creneau.class)
                .setParameter("specialisteId", specialisteId)
                .setParameter("dispo", StatutCreneau.DISPONIBLE)
                .setParameter("now", LocalDateTime.now())
                .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Mettre à jour le statut d'un créneau (Ex: Disponible, Réservé, Indisponible)
     */
    public void updateStatut(Long creneauId, StatutCreneau statut) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Creneau creneau = em.find(Creneau.class, creneauId);
            if (creneau != null) {
                creneau.setStatut(statut);
                em.merge(creneau);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * US6: Mettre à jour automatiquement les créneaux passés en statut ARCHIVE
     */
    public int archiverCreneauxPasses() {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            int updated = em.createQuery(
                "UPDATE Creneau c SET c.statut = :archive WHERE c.heureFin < :now AND c.statut != :archive")
                .setParameter("archive", StatutCreneau.ARCHIVE)
                .setParameter("now", LocalDateTime.now())
                .executeUpdate();
            tx.commit();
            return updated;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
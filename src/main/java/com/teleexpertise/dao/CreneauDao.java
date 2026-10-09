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
     * US3: Récupérer uniquement les créneaux futurs disponibles d'un spécialiste (horaires fixes prédéfinis)
     */
    public List<Creneau> findFutursDisponiblesBySpecialisteId(Long specialisteId) {
        genererCreneauxPredefinisSiVide(specialisteId);
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
     * US3: Initialise des créneaux fixes prédéfinis pour un spécialiste s'il n'en a aucun dans le futur
     * (horaires fixes prédéfinis : ex 09:00-09:30, 09:30-10:00, 10:30-11:00, 14:00-14:30, 15:00-15:30)
     */
    public void genererCreneauxPredefinisSiVide(Long specialisteId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            Long count = em.createQuery(
                    "SELECT COUNT(c) FROM Creneau c WHERE c.specialiste.id = :specialisteId AND c.heureDebut > :now", Long.class)
                    .setParameter("specialisteId", specialisteId)
                    .setParameter("now", LocalDateTime.now())
                    .getSingleResult();

            if (count == 0) {
                tx.begin();
                com.teleexpertise.model.Specialiste specialiste = em.find(com.teleexpertise.model.Specialiste.class, specialisteId);
                if (specialiste != null) {
                    LocalDateTime baseDate = LocalDateTime.now().plusDays(1).withMinute(0).withSecond(0).withNano(0);
                    int[] heures = {9, 10, 11, 14, 15, 16};
                    for (int h : heures) {
                        Creneau creneau1 = new Creneau();
                        creneau1.setSpecialiste(specialiste);
                        creneau1.setHeureDebut(baseDate.withHour(h).withMinute(0));
                        creneau1.setHeureFin(baseDate.withHour(h).withMinute(30));
                        creneau1.setStatut(StatutCreneau.DISPONIBLE);
                        em.persist(creneau1);

                        Creneau creneau2 = new Creneau();
                        creneau2.setSpecialiste(specialiste);
                        creneau2.setHeureDebut(baseDate.withHour(h).withMinute(30));
                        creneau2.setHeureFin(baseDate.withHour(h + 1).withMinute(0));
                        creneau2.setStatut(StatutCreneau.DISPONIBLE);
                        em.persist(creneau2);
                    }
                }
                tx.commit();
            }
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
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

    /**
     * Vérifier si un créneau existe déjà pour ce spécialiste à cette heure précise
     */
    public boolean existeCreneau(Long specialisteId, LocalDateTime heureDebut) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                "SELECT COUNT(c) FROM Creneau c WHERE c.specialiste.id = :specialisteId AND c.heureDebut = :debut", Long.class)
                .setParameter("specialisteId", specialisteId)
                .setParameter("debut", heureDebut)
                .getSingleResult();
            return count > 0;
        } finally {
            em.close();
        }
    }

    /**
     * US6: Créer un nouveau créneau disponible pour un spécialiste
     */
    public Creneau creerCreneau(Long specialisteId, LocalDateTime heureDebut, LocalDateTime heureFin) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            com.teleexpertise.model.Specialiste sp = em.find(com.teleexpertise.model.Specialiste.class, specialisteId);
            Creneau creneau = new Creneau();
            creneau.setSpecialiste(sp);
            creneau.setHeureDebut(heureDebut);
            creneau.setHeureFin(heureFin);
            creneau.setStatut(StatutCreneau.DISPONIBLE);
            em.persist(creneau);
            tx.commit();
            return creneau;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * US6: Supprimer un créneau encore disponible
     */
    public boolean supprimerCreneau(Long creneauId, Long specialisteId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Creneau creneau = em.find(Creneau.class, creneauId);
            if (creneau != null && creneau.getSpecialiste().getId().equals(specialisteId) && creneau.getStatut() == StatutCreneau.DISPONIBLE) {
                em.remove(creneau);
                tx.commit();
                return true;
            }
            tx.commit();
            return false;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * US6: Trouver les créneaux d'un spécialiste pour une date donnée
     */
    public List<Creneau> findBySpecialisteIdAndDate(Long specialisteId, java.time.LocalDate date) {
        LocalDateTime debutJour = date.atStartOfDay();
        LocalDateTime finJour = date.plusDays(1).atStartOfDay();
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT c FROM Creneau c WHERE c.specialiste.id = :specialisteId " +
                "AND c.heureDebut >= :debutJour AND c.heureDebut < :finJour ORDER BY c.heureDebut ASC", Creneau.class)
                .setParameter("specialisteId", specialisteId)
                .setParameter("debutJour", debutJour)
                .setParameter("finJour", finJour)
                .getResultList();
        } finally {
            em.close();
        }
    }
}
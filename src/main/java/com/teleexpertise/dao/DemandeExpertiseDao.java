package com.teleexpertise.dao;

import com.teleexpertise.model.Consultation;
import com.teleexpertise.model.Creneau;
import com.teleexpertise.model.DemandeExpertise;
import com.teleexpertise.model.Priorite;
import com.teleexpertise.model.Specialiste;
import com.teleexpertise.model.StatutConsultation;
import com.teleexpertise.model.StatutCreneau;
import com.teleexpertise.model.StatutExpertise;
import com.teleexpertise.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

import java.time.LocalDateTime;
import java.util.List;

public class DemandeExpertiseDao extends GenericDaoImpl<DemandeExpertise, Long> {

    public DemandeExpertiseDao() {
        super(DemandeExpertise.class);
    }

    /**
     * US3 / Scénario B: Créer la demande d'expertise, passer la consultation à EN_ATTENTE_AVIS_SPECIALISTE et rendre le créneau indisponible
     */
    public DemandeExpertise envoyerDemandeExpertise(Long consultationId, Long specialisteId, Long creneauId, String question, Priorite priorite) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            Consultation consultation = em.find(Consultation.class, consultationId);
            Specialiste specialiste = em.find(Specialiste.class, specialisteId);
            Creneau creneau = em.find(Creneau.class, creneauId);

            // 1. Mettre à jour la consultation (statut EN_ATTENTE_AVIS_SPECIALISTE)
            consultation.setStatut(StatutConsultation.EN_ATTENTE_AVIS_SPECIALISTE);
            em.merge(consultation);

            // 2. Réserver le créneau sélectionné (devient indisponible)
            creneau.setStatut(StatutCreneau.RESERVE);
            em.merge(creneau);

            // 3. Créer et associer la demande d'expertise
            DemandeExpertise demande = new DemandeExpertise();
            demande.setQuestion(question);
            demande.setPriorite(priorite);
            demande.setStatut(StatutExpertise.EN_ATTENTE);
            demande.setDateDemande(LocalDateTime.now());
            demande.setConsultation(consultation);
            demande.setSpecialiste(specialiste);
            demande.setCreneau(creneau);

            em.persist(demande);
            tx.commit();
            return demande;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * US7: Récupérer toutes les demandes reçues par un spécialiste
     */
    public List<DemandeExpertise> findBySpecialisteId(Long specialisteId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT d FROM DemandeExpertise d " +
                "JOIN FETCH d.consultation c " +
                "JOIN FETCH c.patient p " +
                "JOIN FETCH c.generaliste g " +
                "WHERE d.specialiste.id = :specialisteId " +
                "ORDER BY d.dateDemande DESC", DemandeExpertise.class)
                .setParameter("specialisteId", specialisteId)
                .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * US8: Enregistrer l'avis médical et les recommandations du spécialiste, puis marquer la demande comme terminée
     */
    public void repondreAExpertise(Long demandeId, String avisMedical, String recommandations) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            DemandeExpertise demande = em.find(DemandeExpertise.class, demandeId);
            if (demande != null) {
                demande.setAvisMedical(avisMedical);
                demande.setRecommandations(recommandations);
                demande.setStatut(StatutExpertise.TERMINEE);
                demande.setDateReponse(LocalDateTime.now());
                em.merge(demande);
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
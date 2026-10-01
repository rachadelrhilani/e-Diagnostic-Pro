package com.teleexpertise.dao;

import com.teleexpertise.model.ActeMedical;
import com.teleexpertise.model.Consultation;
import com.teleexpertise.model.Generaliste;
import com.teleexpertise.model.Patient;
import com.teleexpertise.model.StatutConsultation;
import com.teleexpertise.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

import java.time.LocalDateTime;

public class ConsultationDao extends GenericDaoImpl<Consultation, Long> {

    public ConsultationDao() {
        super(Consultation.class);
    }

    /**
     * US1 Généraliste: Créer une nouvelle consultation (Coût fixe: 150 DH)
     */
    public Consultation creerConsultation(Long patientId, Long generalisteId, String motif, String observations) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Patient patient = em.find(Patient.class, patientId);
            Generaliste generaliste = em.find(Generaliste.class, generalisteId);

            Consultation consultation = new Consultation();
            consultation.setPatient(patient);
            consultation.setGeneraliste(generaliste);
            consultation.setMotif(motif);
            consultation.setObservations(observations);
            consultation.setCoutBase(150.0);
            consultation.setStatut(StatutConsultation.EN_COURS);
            consultation.setDateConsultation(LocalDateTime.now());

            em.persist(consultation);
            tx.commit();
            return consultation;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Scénario A: Finaliser et clôturer la consultation directe (Diagnostic + Traitement)
     */
    public void cloturerConsultationDirecte(Long consultationId, String diagnostic, String traitement) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Consultation consultation = em.find(Consultation.class, consultationId);
            if (consultation != null) {
                consultation.setDiagnostic(diagnostic);
                consultation.setTraitement(traitement);
                consultation.setStatut(StatutConsultation.TERMINEE);
                em.merge(consultation);
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
     * Actes techniques médicaux: Associer un acte à une consultation (Ex: Radiographie, IRM, Sang)
     */
    public ActeMedical addActeMedical(Long consultationId, ActeMedical acte) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Consultation consultation = em.find(Consultation.class, consultationId);
            if (consultation != null) {
                acte.setConsultation(consultation);
                em.persist(acte);
                consultation.getActesMedicaux().add(acte);
            }
            tx.commit();
            return acte;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Charger une consultation complète avec ses actes techniques et sa demande d'expertise (pour calcul du coût total)
     */
    public Consultation findConsultationComplete(Long consultationId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT DISTINCT c FROM Consultation c " +
                "LEFT JOIN FETCH c.actesMedicaux " +
                "LEFT JOIN FETCH c.demandeExpertise d " +
                "LEFT JOIN FETCH d.specialiste " +
                "WHERE c.id = :id", Consultation.class)
                .setParameter("id", consultationId)
                .getSingleResult();
        } finally {
            em.close();
        }
    }
}
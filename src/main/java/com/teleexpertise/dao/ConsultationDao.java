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
import java.util.Arrays;
import java.util.List;

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
            if (tx.isActive())
                tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Scénario A: Finaliser et clôturer la consultation directe (Diagnostic +
     * Traitement)
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
            if (tx.isActive())
                tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Actes techniques médicaux: Associer un acte à une consultation (Ex:
     * Radiographie, IRM, Sang)
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
            if (tx.isActive())
                tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Charger une consultation complète avec son patient, ses signes vitaux, ses
     * actes techniques
     * et sa demande d'expertise (pour affichage complet et calcul du coût total
     * US4)
     */
    public Consultation findConsultationComplete(Long consultationId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Consultation consultation = em.createQuery(
                    "SELECT DISTINCT c FROM Consultation c " +
                            "JOIN FETCH c.patient p " +
                            "JOIN FETCH c.generaliste g " +
                            "LEFT JOIN FETCH c.actesMedicaux " +
                            "LEFT JOIN FETCH c.demandeExpertise d " +
                            "LEFT JOIN FETCH d.specialiste " +
                            "LEFT JOIN FETCH d.creneau " +
                            "WHERE c.id = :id",
                    Consultation.class)
                    .setParameter("id", consultationId)
                    .getSingleResult();

            // Initialiser les signes vitaux du patient dans la même session JPA
            if (consultation != null && consultation.getPatient() != null
                    && consultation.getPatient().getSignesVitaux() != null) {
                consultation.getPatient().getSignesVitaux().size();
            }

            return consultation;
        } catch (jakarta.persistence.NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public boolean aUneConsultationEnCours(Long patientId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            // Liste des statuts considérés comme "en cours d'attente / de traitement"
            List<StatutConsultation> statutsActifs = Arrays.asList(
                    StatutConsultation.EN_COURS,
                    StatutConsultation.EN_ATTENTE_AVIS_SPECIALISTE);

            Long count = em.createQuery(
                    "SELECT COUNT(c) FROM Consultation c " +
                            "WHERE c.patient.id = :patientId " +
                            "AND c.statut IN :statutsActifs",
                    Long.class)
                    .setParameter("patientId", patientId)
                    .setParameter("statutsActifs", statutsActifs)
                    .getSingleResult();

            return count > 0;
        } finally {
            em.close();
        }
    }

    /**
     * Retourne la consultation active (EN_COURS ou EN_ATTENTE_AVIS_SPECIALISTE) d'un patient, ou null.
     * Utilisé par l'infirmier lors de la recherche NSS pour afficher que le patient est déjà en cours.
     */
    public Consultation findConsultationActiveParPatient(Long patientId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<StatutConsultation> statutsActifs = Arrays.asList(
                    StatutConsultation.EN_COURS,
                    StatutConsultation.EN_ATTENTE_AVIS_SPECIALISTE);
            List<Consultation> list = em.createQuery(
                    "SELECT c FROM Consultation c " +
                    "JOIN FETCH c.patient p " +
                    "JOIN FETCH c.generaliste g " +
                    "WHERE c.patient.id = :patientId " +
                    "AND c.statut IN :statutsActifs " +
                    "ORDER BY c.id DESC",
                    Consultation.class)
                    .setParameter("patientId", patientId)
                    .setParameter("statutsActifs", statutsActifs)
                    .setMaxResults(1)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    public List<Consultation> findConsultationsEnCoursParGeneraliste(Long generalisteId) {
    EntityManager em = JPAUtil.getEntityManager();
    try {
        List<StatutConsultation> statutsActifs = Arrays.asList(
            StatutConsultation.EN_COURS,
            StatutConsultation.EN_ATTENTE_AVIS_SPECIALISTE
        );

        // Les LEFT JOIN FETCH garantissent que toutes les collections nécessaires 
        // au calcul de coutTotal sont chargées en mémoire
        return em.createQuery(
                "SELECT DISTINCT c FROM Consultation c " +
                "JOIN FETCH c.patient p " +
                "LEFT JOIN FETCH c.actesMedicaux " +
                "LEFT JOIN FETCH c.demandeExpertise d " +
                "LEFT JOIN FETCH d.specialiste " +
                "WHERE c.generaliste.id = :generalisteId " +
                "AND c.statut IN :statutsActifs " +
                "ORDER BY c.id DESC",
                Consultation.class)
                .setParameter("generalisteId", generalisteId)
                .setParameter("statutsActifs", statutsActifs)
                .getResultList();
    } finally {
        em.close();
    }
}

    /**
     * Retourne uniquement les consultations EN_COURS (exclut EN_ATTENTE_AVIS_SPECIALISTE).
     * Utilisé pour : blocage création + liste déroulante recherche spécialiste.
     */
    public List<Consultation> findConsultationsEnCoursStrictParGeneraliste(Long generalisteId) {
    EntityManager em = JPAUtil.getEntityManager();
    try {
        return em.createQuery(
                "SELECT DISTINCT c FROM Consultation c " +
                "JOIN FETCH c.patient p " +
                "LEFT JOIN FETCH c.actesMedicaux " +
                "LEFT JOIN FETCH c.demandeExpertise d " +
                "LEFT JOIN FETCH d.specialiste " +
                "WHERE c.generaliste.id = :generalisteId " +
                "AND c.statut = :statut " +
                "ORDER BY c.id DESC",
                Consultation.class)
                .setParameter("generalisteId", generalisteId)
                .setParameter("statut", StatutConsultation.EN_COURS)
                .getResultList();
    } finally {
        em.close();
    }
}
}
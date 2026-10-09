package com.teleexpertise.dao;

import com.teleexpertise.model.Patient;
import com.teleexpertise.model.SignesVitaux;
import com.teleexpertise.model.StatutConsultation;
import com.teleexpertise.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class PatientDao extends GenericDaoImpl<Patient, Long> {

    public PatientDao() {
        super(Patient.class);
    }

    /**
     * US1 - Étape 1: Recherche du patient par numéro de sécurité sociale
     */
    public Optional<Patient> findByNumeroSecuriteSociale(String nss) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Patient patient = em.createQuery(
                    "SELECT p FROM Patient p WHERE p.numeroSecuriteSociale = :nss", Patient.class)
                    .setParameter("nss", nss)
                    .getSingleResult();
            return Optional.of(patient);
        } catch (NoResultException e) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    /**
     * US1 - Étape 2a: Saisir de nouveaux signes vitaux pour un patient existant
     */
    public SignesVitaux addSignesVitaux(Long patientId, SignesVitaux signes) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Patient patient = em.find(Patient.class, patientId);
            if (patient != null) {
                signes.setPatient(patient);
                signes.setDatePrise(LocalDateTime.now());
                em.persist(signes);
                patient.getSignesVitaux().add(signes);
            }
            tx.commit();
            return signes;
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * US1 - Étape 2b: Créer un nouveau patient avec ses signes vitaux initiaux
     */
    public Patient enregistrerNouveauPatient(Patient patient, SignesVitaux signes) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(patient);

            if (signes != null) {
                signes.setPatient(patient);
                signes.setDatePrise(LocalDateTime.now());
                em.persist(signes);
                patient.getSignesVitaux().add(signes);
            }
            tx.commit();
            return patient;
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * US2: Récupérer tous les patients enregistrés avec leurs signes vitaux (pour
     * filtrage Stream)
     */
    public List<Patient> findAllWithSignesVitaux() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT DISTINCT p FROM Patient p LEFT JOIN FETCH p.signesVitaux ORDER BY p.id ASC", Patient.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<Patient> findPatientsEnAttente() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            // En sélectionnant c.dateConsultation dans le SELECT, le DISTINCT et le ORDER
            // BY fonctionnent ensemble
            List<Object[]> resultats = em.createQuery(
                    "SELECT DISTINCT p, c.dateConsultation FROM Patient p " +
                            "JOIN p.consultations c " +
                            "LEFT JOIN FETCH p.signesVitaux " +
                            "WHERE c.statut = :statut " +
                            "ORDER BY c.dateConsultation ASC",
                    Object[].class)
                    .setParameter("statut", StatutConsultation.EN_COURS)
                    .getResultList();

            // Extraire uniquement l'entité Patient du tableau d'objets
            return resultats.stream()
                    .map(row -> (Patient) row[0])
                    .distinct()
                    .collect(Collectors.toList());
        } finally {
            em.close();
        }
    }
}
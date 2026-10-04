package com.teleexpertise.service;

import com.teleexpertise.dao.PatientDao;
import com.teleexpertise.model.Patient;
import com.teleexpertise.model.SignesVitaux;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class InfirmierServiceTest {

    @Mock
    private PatientDao patientDao;

    @InjectMocks
    private InfirmierService infirmierService;

    private Patient patient1;
    private Patient patient2;

    @BeforeEach
    void setUp() {
        patient1 = new Patient();
        patient1.setId(1L);
        patient1.setNom("El Amrani");
        patient1.setPrenom("Youssef");
        patient1.setNumeroSecuriteSociale("123456789");

        SignesVitaux sv1 = new SignesVitaux();
        sv1.setDatePrise(LocalDateTime.now().minusHours(2)); // Enregistré aujourd'hui à H-2
        patient1.getSignesVitaux().add(sv1);

        patient2 = new Patient();
        patient2.setId(2L);
        patient2.setNom("Bennani");
        patient2.setPrenom("Khadija");
        patient2.setNumeroSecuriteSociale("987654321");

        SignesVitaux sv2 = new SignesVitaux();
        sv2.setDatePrise(LocalDateTime.now().minusHours(4)); // Enregistré aujourd'hui à H-4 (Plus ancien)
        patient2.getSignesVitaux().add(sv2);
    }

    @Test
    void testRechercherPatientParNss_Succes() {
        when(patientDao.findByNumeroSecuriteSociale("123456789")).thenReturn(Optional.of(patient1));

        Optional<Patient> resultat = infirmierService.rechercherPatientParNss("123456789");

        assertTrue(resultat.isPresent());
        assertEquals("El Amrani", resultat.get().getNom());
        verify(patientDao, times(1)).findByNumeroSecuriteSociale("123456789");
    }

    @Test
    void testGetPatientsDuJour_FiltrageEtTriStreamAPI() {
        // Patient enregistré hier (ne doit pas être inclus)
        Patient patientHier = new Patient();
        patientHier.setId(3L);
        SignesVitaux svHier = new SignesVitaux();
        svHier.setDatePrise(LocalDateTime.now().minusDays(1));
        patientHier.getSignesVitaux().add(svHier);

        when(patientDao.findAllWithSignesVitaux()).thenReturn(Arrays.asList(patient1, patient2, patientHier));

        List<Patient> resultat = infirmierService.getPatientsDuJour();

        // Vérifications
        assertEquals(2, resultat.size(), "Seuls 2 patients enregistrés aujourd'hui doivent être retenus");
        assertEquals("Bennani", resultat.get(0).getNom(), "Le patient arrivé à H-4 doit être en premier (tri chrono)");
        assertEquals("El Amrani", resultat.get(1).getNom(), "Le patient arrivé à H-2 doit être en second");
        
        verify(patientDao, times(1)).findAllWithSignesVitaux();
    }
}
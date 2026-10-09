package com.teleexpertise.service;

import com.teleexpertise.dao.ConsultationDao;
import com.teleexpertise.dao.CreneauDao;
import com.teleexpertise.dao.DemandeExpertiseDao;
import com.teleexpertise.dao.SpecialisteDao;
import com.teleexpertise.model.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class GeneralisteServiceTest {

    @Mock
    private ConsultationDao consultationDao;
    @Mock
    private SpecialisteDao specialisteDao;
    @Mock
    private CreneauDao creneauDao;
    @Mock
    private DemandeExpertiseDao demandeExpertiseDao;

    @InjectMocks
    private GeneralisteService generalisteService;

    private Specialiste specChère;
    private Specialiste specAbordable;

    @BeforeEach
    void setUp() {
        specChère = new Specialiste("Alami", "Dr. Hassan", "hassan@med.ma", "pass", "Cardiologue", 400.0);
        specAbordable = new Specialiste("Tazi", "Dr. Meriem", "meriem@med.ma", "pass", "Cardiologue", 250.0);
    }

    @Test
    void testRechercherEtTrierSpecialistes_StreamAPI() {
        when(specialisteDao.findBySpecialite("Cardiologue"))
                .thenReturn(Arrays.asList(specChère, specAbordable));

        // Filtrer les spécialistes avec un tarif max de 300 DH
        List<Specialiste> resultat = generalisteService.rechercherEtTrierSpecialistes("Cardiologue", 300.0);

        assertEquals(1, resultat.size());
        assertEquals("Tazi", resultat.get(0).getNom());
        assertEquals(250.0, resultat.get(0).getTarif());
    }

    @Test
    void testCalculerCoutTotal_AvecLambdaMapSum() {
        Consultation consultation = new Consultation();
        consultation.setId(10L);
        consultation.setCoutBase(150.0); // 150 DH fixe

        // Ajout d'actes techniques
        ActeMedical radio = new ActeMedical("Radiographie", 200.0);
        ActeMedical sang = new ActeMedical("Analyse de sang", 100.0);
        consultation.setActesMedicaux(Arrays.asList(radio, sang));

        // Ajout demande d'expertise
        DemandeExpertise demande = new DemandeExpertise();
        demande.setSpecialiste(specAbordable); // Tarif : 250 DH
        consultation.setDemandeExpertise(demande);

        when(consultationDao.findConsultationComplete(10L)).thenReturn(consultation);

        // Calcul attendu : 150 (Base) + 200 (Radio) + 100 (Sang) + 250 (Spécialiste) = 700 DH
        double coutTotal = generalisteService.calculerCoutTotal(10L);

        assertEquals(700.0, coutTotal, 0.001);
        verify(consultationDao, times(1)).findConsultationComplete(10L);
    }

    @Test
    void testCreerConsultation_US1() {
        Consultation consult = new Consultation();
        consult.setId(1L);
        consult.setCoutBase(150.0);
        consult.setMotif("Céphalées intenses");
        consult.setObservations("Patient fébrile");

        when(consultationDao.creerConsultation(100L, 200L, "Céphalées intenses", "Patient fébrile"))
                .thenReturn(consult);

        Consultation res = generalisteService.creerConsultation(100L, 200L, "Céphalées intenses", "Patient fébrile");

        assertNotNull(res);
        assertEquals(150.0, res.getCoutBase());
        assertEquals("Céphalées intenses", res.getMotif());
        verify(consultationDao).creerConsultation(100L, 200L, "Céphalées intenses", "Patient fébrile");
    }

    @Test
    void testDemanderExpertise_US3() {
        DemandeExpertise demande = new DemandeExpertise();
        demande.setId(5L);
        demande.setPriorite(Priorite.URGENTE);
        demande.setQuestion("Avis ECG");

        when(demandeExpertiseDao.envoyerDemandeExpertise(1L, 2L, 3L, "Avis ECG", Priorite.URGENTE))
                .thenReturn(demande);

        DemandeExpertise res = generalisteService.demanderExpertise(1L, 2L, 3L, "Avis ECG", Priorite.URGENTE);

        assertNotNull(res);
        assertEquals(Priorite.URGENTE, res.getPriorite());
        assertEquals("Avis ECG", res.getQuestion());
        verify(demandeExpertiseDao).envoyerDemandeExpertise(1L, 2L, 3L, "Avis ECG", Priorite.URGENTE);
    }

    @Test
    void testCalculerCoutTotal_SansActesNiExpertise_US4() {
        Consultation consultation = new Consultation();
        consultation.setId(20L);
        consultation.setCoutBase(150.0);

        when(consultationDao.findConsultationComplete(20L)).thenReturn(consultation);

        double coutTotal = generalisteService.calculerCoutTotal(20L);

        // Doit être exactement le montant fixe de consultation : 150 DH
        assertEquals(150.0, coutTotal, 0.001);
    }
}
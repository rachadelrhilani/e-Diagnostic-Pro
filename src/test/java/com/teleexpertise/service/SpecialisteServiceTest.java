package com.teleexpertise.service;

import com.teleexpertise.dao.CreneauDao;
import com.teleexpertise.dao.DemandeExpertiseDao;
import com.teleexpertise.dao.UtilisateurDao;
import com.teleexpertise.model.DemandeExpertise;
import com.teleexpertise.model.Priorite;
import com.teleexpertise.model.StatutExpertise;
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
class SpecialisteServiceTest {

    @Mock
    private UtilisateurDao utilisateurDao;
    @Mock
    private CreneauDao creneauDao;
    @Mock
    private DemandeExpertiseDao demandeExpertiseDao;

    @InjectMocks
    private SpecialisteService specialisteService;

    private DemandeExpertise demandeUrgente;
    private DemandeExpertise demandeNormale;

    @BeforeEach
    void setUp() {
        demandeUrgente = new DemandeExpertise();
        demandeUrgente.setStatut(StatutExpertise.EN_ATTENTE);
        demandeUrgente.setPriorite(Priorite.URGENTE);

        demandeNormale = new DemandeExpertise();
        demandeNormale.setStatut(StatutExpertise.TERMINEE);
        demandeNormale.setPriorite(Priorite.NORMALE);
    }

    @Test
    void testConsulterDemandesFiltrees_StreamAPI() {
        when(demandeExpertiseDao.findBySpecialisteId(1L))
                .thenReturn(Arrays.asList(demandeUrgente, demandeNormale));

        // Filtrer uniquement les demandes EN_ATTENTE et URGENTES
        List<DemandeExpertise> resultat = specialisteService.consulterDemandesFiltrees(
                1L, StatutExpertise.EN_ATTENTE, Priorite.URGENTE);

        assertEquals(1, resultat.size());
        assertEquals(Priorite.URGENTE, resultat.get(0).getPriorite());
        assertEquals(StatutExpertise.EN_ATTENTE, resultat.get(0).getStatut());
    }

    @Test
    void testConsulterCreneaux_ArchivageAutomatique() {
        specialisteService.consulterCreneaux(1L);

        // Vérifier que l'archivage automatique des créneaux passés a bien été déclenché
        verify(creneauDao, times(1)).archiverCreneauxPasses();
        verify(creneauDao, times(1)).findBySpecialisteId(1L);
    }

    @Test
    void testConfigurerProfil() {
        specialisteService.configurerProfil(1L, "Cardiologie", 350.0);
        verify(utilisateurDao, times(1)).updateProfilSpecialiste(1L, "Cardiologie", 350.0);
    }

    @Test
    void testCreerDisponibilites_IgnorerCreneauxPasses() {
        // Pour une date passée : doit lever IllegalArgumentException
        java.time.LocalDate datePassee = java.time.LocalDate.now().minusDays(1);
        assertThrows(IllegalArgumentException.class, () -> {
            specialisteService.creerDisponibilites(1L, datePassee, List.of(java.time.LocalTime.of(10, 0)));
        });

        // Pour demain : tous les créneaux futurs sont créés
        java.time.LocalDate dateDemain = java.time.LocalDate.now().plusDays(1);
        java.time.LocalTime heure1 = java.time.LocalTime.of(9, 0);
        java.time.LocalTime heure2 = java.time.LocalTime.of(10, 0);

        when(creneauDao.existeCreneau(eq(1L), any(java.time.LocalDateTime.class))).thenReturn(false);

        int crees = specialisteService.creerDisponibilites(1L, dateDemain, List.of(heure1, heure2));
        assertEquals(2, crees);
        verify(creneauDao, times(2)).creerCreneau(eq(1L), any(java.time.LocalDateTime.class), any(java.time.LocalDateTime.class));
    }

    @Test
    void testRepondreAExpertise() {
        specialisteService.repondreAExpertise(10L, "Diagnostic cardiologique", "Traitement bêtabloquant");
        verify(demandeExpertiseDao, times(1)).repondreAExpertise(10L, "Diagnostic cardiologique", "Traitement bêtabloquant");
    }
}
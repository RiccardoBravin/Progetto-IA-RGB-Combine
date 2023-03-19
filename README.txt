Project for the Basis of Artificial Intelligence in UniPD

This project entails both research and development of a method to combine 16 grayscale images of planktic foraminifera into one with RGB colors. This was made so to be able to use the generated images for the finetuning of ResNet50.

Published paper can be found at: https://www.preprints.org/manuscript/202302.0396/v1

Progetto realizzato da Bravin Riccardo (1218660) e Feltrin Elia ()

Per avviare un dato processing entrare nella cartella /Processing e scegliere il metodo da cui generare immagini. Inserendo la scelta per la randomizzazione dell'immagine di partenza e nel caso del metodo RGB anche il valore groupBy

Tutte le immagini generate da ogni metodo sono già presenti nella cartella /Processing sotto il relativo nome

Per effettuare il training su 4 fold, avviare k_fold_training.m avendo cura di scegliere la cartella all'interno di cui è presente il dataset generato con il metodo scelto. I risultati generati verranno salvati all'interno di /Results con il rispettivo nome del metodo scelto

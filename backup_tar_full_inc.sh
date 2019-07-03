#!/usr/bin/env bash

################################
#### SCRIPT DE BACKUP LINUX ####
#### DESENV POR MARIO NETO  ####
#### VER 1.0                ####
################################

### VARIAVEIS ###
DATA=$(date +%Y-%m-%d.%H.%M.%S)
DIASEMANA=$(date +%w)

ORIGEM="/mnt/Data/"
DESTINO="/mnt/Backup"
LOGLOCAL="/mnt/Backup/log"

LOGFULLOUT="${LOGLOCAL}/backup-full.${DATA}.${DIASEMANA}.log"
LOGFULLERR="${LOGLOCAL}/backup-full.${DATA}.${DIASEMANA}.err"
LOGCTRL="${LOGLOCAL}/controle.txt"

LOGINCOUT="${LOGLOCAL}/backup-incremental.${DATA}.${DIASEMANA}.log"
LOGINCERR="${LOGLOCAL}/backup-incremental.${DATA}.${DIASEMANA}.err"

FULLFILE="backup-full.${DATA}.${DIASEMANA}.tar"
INCRFILE="backup-incremental.${DATA}.${DIASEMANA}.tar"

# DIAFULL corresponde com o dia da semana segundo o comando data Domingo(0) Segunda(1) Terca(2) Quarta(3) Quinta(4) Sexta(5) Sabado(6)
DIAFULL="5"
RETENCAOFULL="30"
RETENCAOINCR="14"
EMAIL="email@provedor.com"

### FUNCOES ###
backup_full() {
	tar vvvcf ${DESTINO}/${FULLFILE} --exclude=${ORIGEM}/Completo ${ORIGEM} > ${LOGFULLOUT} 2> ${LOGFULLERR}
}

controle() {
	awk '{print $6}' ${LOGFULLOUT} > ${LOGCTRL}
}

backup_incremental() {
	tar vvvcf ${DESTINO}/${INCRFILE} -g ${LOGCTRL} ${ORIGEM} > ${LOGINCOUT} 2> ${LOGINCERR}
}

mail_full() {
	mailx -s "Log de backup full - ${DATA}" ${EMAIL} < ${LOGFULLOUT}
}

mail_full_err() {
	mailx -s "Log de backup full com erro - ${DATA}" ${EMAIL} < ${LOGFULLERR}
}

mail_incr() {
	mailx -s "Log de backup incremental - ${DATA}" ${EMAIL} < ${LOGINCOUT}
}

mail_incr_err() {
	mailx -s "Log de backup incremental com erro - ${DATA}" ${EMAIL} < ${LOGINCERR}
}

limpa_log_full() {
	find ${LOGLOCAL} -type f -regex "backup-full\.*\.(err|log)" -mtime +${RETENCAOFULL} -exec rm -f '{}' \;
}

limpa_bkp_full() {
	find ${DESTINO} -type f -regex "backup-full\.*\.tar" -mtime +${RETENCAOFULL} -exec rm -f '{}' \;
}

limpa_log_incr() {
	find ${LOGLOCAL} -type f -regex "backup-incremental\.*\.(err|log)" -mtime +${RETENCAOINCR} -exec rm -f '{}' \;
}

limpa_bkp_incr() {
	find ${DESTINO} -type f -regex "backup-incremental\.*\.tar" -mtime +${RETENCAOINCR} -exec rm -f '{}' \;
}

### EXECUCAO BACKUP ####
if [ $DIAFULL -eq ${DIASEMANA} ]; then
	backup_full
	controle
	mail_full
	if [ -s ${LOGFULLERR} ]; then
		mail_full_err
	fi
else
	backup_incremental
	mail_incr
	if [ -s ${LOGINCERR} ]; then
		mail_incr_err
	fi
fi

### LIMPEZA ###
limpa_log_full
limpa_log_incr
limpa_bkp_full
limpa_bkp_incr

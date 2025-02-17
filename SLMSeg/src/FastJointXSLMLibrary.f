       SUBROUTINE BIOVITERBI(ETAV,P,EMISSION,T,KTILDE,PATH,PSI)

       IMPLICIT NONE
       INTEGER T,KTILDE,IND,PATH(T),PSI(KTILDE,T),I,J,K
       DOUBLE PRECISION NUMMAX
       DOUBLE PRECISION ETAV(KTILDE),EMISSION(KTILDE,T)
       DOUBLE PRECISION P(KTILDE,KTILDE),DELTA(KTILDE,T)


       DO 202 I=1,KTILDE
          DELTA(I,1)=ETAV(I)+EMISSION(I,1)
          PSI(I,1)=0
 202   CONTINUE

       DO 203 I=2,T
          DO 213 J=1,KTILDE
             NUMMAX=0.0
             NUMMAX=DELTA(1,I-1)+P(1,J)
             IND=1
             DO 223 K=2,KTILDE
                IF((DELTA(K,I-1)+P(K,J)).GT.NUMMAX) THEN
                   NUMMAX=(DELTA(K,I-1)+P(K,J))
                   IND=K
                ENDIF
 223         CONTINUE
             PSI(J,I)=IND
             DELTA(J,I)=NUMMAX+EMISSION(J,I)
 213      CONTINUE

 203   CONTINUE

       NUMMAX=0.0
       NUMMAX=DELTA(1,T)
       IND=1
       DO 253 K=2,KTILDE
          IF(DELTA(K,T).GT.NUMMAX) THEN
             NUMMAX=DELTA(K,T)
             IND=K
           ENDIF
 253   CONTINUE
       
       PATH(T)=IND
       DO 263 K=T-1,1,-1
          PATH(K)=PSI(PATH(K+1),K+1)
 263   CONTINUE

       RETURN
       END




       SUBROUTINE TRANSEMIS(MUK,MI,ETA,TOTALSEQ,KTILDE,
     c NUMSEQ,SMU,SEPSILON,T,G,P,EMISSION)

       IMPLICIT NONE
       INTEGER T,KTILDE,NUMSEQ,I,J,K
       DOUBLE PRECISION NORM,GSUP,ETA,PI,ELNSUM
       DOUBLE PRECISION MI(NUMSEQ),P(KTILDE,KTILDE)
       DOUBLE PRECISION GVECT(KTILDE)
       DOUBLE PRECISION G(KTILDE,KTILDE)
       DOUBLE PRECISION EMISSION(KTILDE,T)
       DOUBLE PRECISION MUK(NUMSEQ,KTILDE)
       DOUBLE PRECISION TOTALSEQ(NUMSEQ,T)
       DOUBLE PRECISION SMU(NUMSEQ),SEPSILON(NUMSEQ)
       PARAMETER(PI=3.14159265358979)


       DO 627 I=1,KTILDE
             GSUP=0
             DO 617 J=1,NUMSEQ
                GSUP=GSUP+(-(((MUK(J,I)-MI(J))**2)/(2*SMU(J)**2)))
 617         CONTINUE
             GVECT(I)=GSUP
 627   CONTINUE
       
       NORM=GVECT(1)
       IF (KTILDE.GT.1) THEN
       DO 607 J=2,KTILDE
          NORM=ELNSUM(NORM,GVECT(J))
 607   CONTINUE
       ENDIF

       DO 700 I=1,KTILDE
          DO 702 J=1,KTILDE
             G(I,J)=GVECT(J)-NORM
 702      CONTINUE
 700   CONTINUE


       DO 710 J=1,KTILDE
              DO 720 K=1,KTILDE
                 IF (J.EQ.K) THEN
                    P(J,K)=ELNSUM(LOG(1-ETA),(LOG(ETA)+G(J,K)))
                    ELSE
                    P(J,K)=LOG(ETA)+G(J,K)
                 ENDIF
 720          CONTINUE
 710   CONTINUE

       DO 730 J=1,KTILDE
          DO 740 K=1,T
             DO 741 I=1,NUMSEQ
              EMISSION(J,K)=EMISSION(J,K)+LOG(1/
     c        (SQRT(2*PI)*SEPSILON(I)))+(-0.5*((TOTALSEQ(I,K)-
     c        MUK(I,J))/(SEPSILON(I)))**2)
 741         CONTINUE
 740      CONTINUE
 730   CONTINUE
       RETURN
       END 



       SUBROUTINE BIOVITERBII(ETAV,P,EMISSION,T,KTILDE,PATH,PSI)

       IMPLICIT NONE
       INTEGER T,KTILDE,IND,PATH(T),PSI(KTILDE,T),I,J,K,COUNTP
       DOUBLE PRECISION NUMMAX
       DOUBLE PRECISION ETAV(KTILDE),EMISSION(KTILDE,T)
       DOUBLE PRECISION P(KTILDE,KTILDE),DELTA(KTILDE,T)


       DO 302 I=1,KTILDE
          DELTA(I,1)=ETAV(I)+EMISSION(I,1)
          PSI(I,1)=0
 302   CONTINUE

       COUNTP=0
       DO 303 I=2,T
          DO 313 J=1,KTILDE
             NUMMAX=0.0
             NUMMAX=DELTA(1,I-1)+P(1,(J+COUNTP))
             IND=1
             DO 323 K=2,KTILDE
                IF((DELTA(K,I-1)+P(K,(J+COUNTP))).GT.NUMMAX) THEN
                   NUMMAX=(DELTA(K,I-1)+P(K,(J+COUNTP)))
                   IND=K
                ENDIF
 323         CONTINUE
             PSI(J,I)=IND
             DELTA(J,I)=NUMMAX+EMISSION(J,I)
 313      CONTINUE
          COUNTP=COUNTP+KTILDE
 303   CONTINUE

       NUMMAX=0.0
       NUMMAX=DELTA(1,T)
       IND=1
       DO 353 K=2,KTILDE
          IF(DELTA(K,T).GT.NUMMAX) THEN
             NUMMAX=DELTA(K,T)
             IND=K
           ENDIF
 353   CONTINUE

       PATH(T)=IND
       DO 363 K=T-1,1,-1
          PATH(K)=PSI(PATH(K+1),K+1)
 363   CONTINUE

       RETURN
       END


       SUBROUTINE TRANSEMISI(MUK,MI,ETA,NCOV,TOTALSEQ,KTILDE,
     c NUMSEQ,SMU,SEPSILON,T,G,P,EMISSION)

       IMPLICIT NONE
       INTEGER T,KTILDE,NUMSEQ,I,J,K,COUNTP,NCOV
       DOUBLE PRECISION NORM,GSUP,ETA(NCOV),PI,ELNSUM
       DOUBLE PRECISION MI(NUMSEQ),P(KTILDE,KTILDE*NCOV)
       DOUBLE PRECISION GVECT(KTILDE)
       DOUBLE PRECISION G(KTILDE,KTILDE)
       DOUBLE PRECISION EMISSION(KTILDE,T)
       DOUBLE PRECISION MUK(NUMSEQ,KTILDE)
       DOUBLE PRECISION TOTALSEQ(NUMSEQ,T)
       DOUBLE PRECISION SMU(NUMSEQ),SEPSILON(NUMSEQ)
       PARAMETER(PI=3.14159265358979)


       DO 727 I=1,KTILDE
             GSUP=0
             DO 717 J=1,NUMSEQ
                GSUP=GSUP+(-(((MUK(J,I)-MI(J))**2)/(2*SMU(J)**2)))
 717         CONTINUE
             GVECT(I)=GSUP
 727   CONTINUE

       NORM=GVECT(1)
       IF (KTILDE.GT.1) THEN
       DO 707 J=2,KTILDE
          NORM=ELNSUM(NORM,GVECT(J))
 707   CONTINUE
       ENDIF

       DO 800 I=1,KTILDE
          DO 802 J=1,KTILDE
             G(I,J)=GVECT(J)-NORM
 802      CONTINUE
 800   CONTINUE

       COUNTP=0
       DO 810 I=1,NCOV
           DO 820 J=1,KTILDE
               DO 850 K=1,KTILDE
                   IF (J.EQ.K) THEN
                      P(J,(K+COUNTP))=ELNSUM(LOG(1-ETA(I)),(LOG(ETA(I))+
     c                G(J,K)))
                      ELSE
                      P(J,(K+COUNTP))=LOG(ETA(I))+G(J,K)
                   ENDIF
 850           CONTINUE
 820       CONTINUE
           COUNTP=COUNTP+KTILDE
 810   CONTINUE


       DO 830 J=1,KTILDE
          DO 840 K=1,T
             DO 841 I=1,NUMSEQ
              EMISSION(J,K)=EMISSION(J,K)+LOG(1/
     c        (SQRT(2*PI)*SEPSILON(I)))+(-0.5*((TOTALSEQ(I,K)-
     c        MUK(I,J))/(SEPSILON(I)))**2)
 841         CONTINUE
 840      CONTINUE
 830   CONTINUE
       RETURN
       END 







      DOUBLE PRECISION FUNCTION ELNSUM(X,Y)

      IMPLICIT NONE
      DOUBLE PRECISION X,Y
      IF (X.GT.Y) THEN
         ELNSUM=X+LOG(1+EXP(Y-X))
      ELSE
         ELNSUM=Y+LOG(1+EXP(X-Y))
      ENDIF

      RETURN
      END



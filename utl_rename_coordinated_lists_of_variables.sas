Renameing long corrdinated lists of variables %renamel(old = a b c , new = x y z (Yoda Ian Whitlock)

 Before we start it is worth noting that SAS supports

   (rename=(a1-a10=demo_1-demo_10))   ** use this for arrays

WORKING CODE (macro on end)
WPS/SAS (same results)
============================

   %renamel(old = a b c , new = x y z)


inspired by
Ian Whitlock

and

https://goo.gl/UmhYNw
https://communities.sas.com/t5/SASware-Ballot-Ideas/Enhanced-RENAME-syntax-to-handle-variable-lists/idi-p/401758

HAVE (Two datasets with the same name but different data)
=========================================================

   WORK.HAVE1 total obs=1

   Obs    K    A    B    C

    1     1    1    2    3


   WORK.HAVE2 total obs=1

   Obs    K    A    B    C

    1     1    6    7    8


WANT
====

  WORK.WANT total obs=1

  Obs    K    X    Y    Z    A    B    C

   1     1    1    2    3    6    7    8

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have1 ;
   input k a b c ;
cards4 ;
1 1 2 3
;;;;
run;quit;


data have2 ;
   input k a b c ;
cards4 ;
1 6 7 8
;;;;
run;quit;

data want ;
   merge have1 ( rename = ( %utl_renamel(old = a b c , new = x y z) ) )
         have2 ;
   by k ;
run ;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_wps64('
libname wrk "%sysfunc(pathname(work))";
data wrk.want ;
   merge wrk.have1 ( rename = ( %utl_renamel(old = a b c , new = x y z) ) )
         wrk.have2 ;
   by k ;
run;quit;
');

proc print data = want ;
run ;

*
 _ __ ___   __ _  ___ _ __ ___
| '_ ` _ \ / _` |/ __| '__/ _ \
| | | | | | (_| | (__| | | (_) |
|_| |_| |_|\__,_|\___|_|  \___/

;

/* From:Ian Whitlock <whitloi1@WESTATPO.WESTAT.COM> */

    Here is a macro, RENAMEL, to use with renameing long corrdinated lists
    of variables.

       %macro utl_renamel ( old= , new= ) ;
           /* Take two cordinated lists &old and &new and  */
           /* return another list of corresponding pairs   */
           /* separated by equal sign for use in a rename  */
           /* statement or data set option.                */
           /*                                              */
           /*  usage:                                      */
           /*    rename = (%renamel(old=A B C, new=X Y Z)) */
           /*    rename %renamel(old=A B C, new=X Y Z);    */
           /*                                              */
           /* Ref: Ian Whitlock <whitloi1@westat.com>      */

           %local i u v warn ;
           %let warn = Warning: RENAMEL old and new lists ;
           %let i = 1 ;
           %let u = %scan ( &old , &i ) ;
           %let v = %scan ( &new , &i ) ;
           %do %while ( %quote(&u)^=%str() and %quote(&v)^=%str() ) ;
               &u = &v
               %let i = %eval ( &i + 1 ) ;
               %let u = %scan ( &old , &i ) ;
               %let v = %scan ( &new , &i ) ;
           %end ;

           %if (null&u ^= null&v) %then
               %put &warn do not have same number of elements. ;

       %mend  utl_renamel ;

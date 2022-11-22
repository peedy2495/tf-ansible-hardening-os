#!/bin/bash

#############################################################################
#                                                                           #
# analyze compiler-options of executables and libraries reachable by $PATH  #
#                                                                           #
# package dependencies:                                                     #
# - devscripts                                                              #
# - binutils                                                                #
# - elfutils                                                                #
#                                                                           #
#############################################################################

echo "[+] Clearing Files"
echo > /tmp/executables
echo > /tmp/executables_suid
echo > /tmp/libraries
echo > /tmp/executables_results
echo > /tmp/executables_suid_results
echo > /tmp/libraries_results
echo > /tmp/binary_report
echo "[+] Finding Executables and SUID Binaries"
for i in $(echo $PATH | tr ":" "\n")
do
find $i -type f -executable -print >> /tmp/executables 2>/dev/null
find $i -perm -4000 >> /tmp/executables_suid 2>/dev/null
done
echo "[+] Finding Libraries"
for i in $(cat /tmp/executables)
do
ldd $i | sed 's:^[^/]*::;s/ .*//' 2>/dev/null
done | sort -u | grep -v '^$' >/tmp/libraries
echo "[+] Analyzing Executables"
for i in $(cat /tmp/executables)
do
hardening-check $i >> /tmp/executables_results 2>/dev/null
done
echo "[+] Analyzing SUID Binaries"
for i in $(cat /tmp/executables_suid)
do
hardening-check $i >> /tmp/executables_suid_results 2>/dev/null
done
echo "[+] Analyzing Libraries"
for i in $(cat /tmp/libraries)
do
hardening-check $i >> /tmp/libraries_results 2>/dev/null
done
echo "[+] Calculating results"
EXECUTABLES=$(cat /tmp/executables_results | grep Position | wc -l )
EXECUTABLES_PIE_YES=$(cat /tmp/executables_results | grep " Position Independent Executable: yes" | wc -l )
EXECUTABLES_PIE_NO=$(cat /tmp/executables_results | grep " Position Independent Executable" | grep -v " Position Independent Executable: yes" | wc -l )
EXECUTABLES_PIE_PERCENT=$(awk -vn=$EXECUTABLES_PIE_YES -vm=$EXECUTABLES_PIE_NO 'BEGIN{print((n/(n+m))*100)}')
EXECUTABLES_SP_YES=$(cat /tmp/executables_results | grep " Stack protected: yes" | wc -l )
EXECUTABLES_SP_NO=$(cat /tmp/executables_results | grep " Stack protected" | grep -v " Stack protected: yes" | wc -l )
EXECUTABLES_SP_PERCENT=$(awk -vn=$EXECUTABLES_SP_YES -vm=$EXECUTABLES_SP_NO 'BEGIN{print((n/(n+m))*100)}')
EXECUTABLES_FS_YES=$(cat /tmp/executables_results | grep " Fortify Source functions: yes" | wc -l )
EXECUTABLES_FS_NO=$(cat /tmp/executables_results | grep " Fortify Source functions" | grep -v " Fortify Source functions: yes" | wc -l )
EXECUTABLES_FS_PERCENT=$(awk -vn=$EXECUTABLES_FS_YES -vm=$EXECUTABLES_FS_NO 'BEGIN{print((n/(n+m))*100)}')
EXECUTABLES_ROR_YES=$(cat /tmp/executables_results | grep " Read-only relocations: yes" | wc -l)
EXECUTABLES_ROR_NO=$(cat /tmp/executables_results | grep " Read-only relocations" | grep -v " Read-only relocations: yes" | wc -l )
EXECUTABLES_ROR_PERCENT=$(awk -vn=$EXECUTABLES_ROR_YES -vm=$EXECUTABLES_ROR_NO 'BEGIN{print((n/(n+m))*100)}')
EXECUTABLES_IB_YES=$(cat /tmp/executables_results | grep " Immediate binding: yes" | wc -l ) EXECUTABLES_IB_NO=$(cat /tmp/executables_results | grep " Immediate binding" | grep -v " Immediate binding: yes" | wc -l )
EXECUTABLES_IB_PERCENT=$(awk -vn=$EXECUTABLES_IB_YES -vm=$EXECUTABLES_IB_NO 'BEGIN{print((n/(n+m))*100)}')
SUID=$(cat /tmp/executables_suid_results | grep Position | wc -l )
SUID_PIE_YES=$(cat /tmp/executables_suid_results | grep " Position Independent Executable: yes" | wc -l )
SUID_PIE_NO=$(cat /tmp/executables_suid_results | grep " Position Independent Executable" | grep -v " Position Independent Executable: yes" | wc -l )
SUID_PIE_PERCENT=$(awk -vn=$SUID_PIE_YES -vm=$SUID_PIE_NO 'BEGIN{print((n/(n+m))*100)}')
SUID_SP_YES=$(cat /tmp/executables_suid_results | grep " Stack protected: yes" | wc -l )
SUID_SP_NO=$(cat /tmp/executables_suid_results | grep " Stack protected" | grep -v " Stack protected: yes" | wc -l )
SUID_SP_PERCENT=$(awk -vn=$SUID_SP_YES -vm=$SUID_SP_NO 'BEGIN{print((n/(n+m))*100)}')
SUID_FS_YES=$(cat /tmp/executables_suid_results | grep " Fortify Source functions: yes" | wc -l )
SUID_FS_NO=$(cat /tmp/executables_suid_results | grep " Fortify Source functions" | grep -v " Fortify Source functions: yes" | wc -l )
SUID_FS_PERCENT=$(awk -vn=$SUID_FS_YES -vm=$SUID_FS_NO 'BEGIN{print((n/(n+m))*100)}')
SUID_ROR_YES=$(cat /tmp/executables_suid_results | grep " Read-only relocations: yes" | wc -l )
SUID_ROR_NO=$(cat /tmp/executables_suid_results | grep " Read-only relocations" | grep -v " Read-only relocations: yes" | wc -l )
SUID_ROR_PERCENT=$(awk -vn=$SUID_ROR_YES -vm=$SUID_ROR_NO 'BEGIN{print((n/(n+m))*100)}')
SUID_IB_YES=$(cat /tmp/executables_suid_results | grep " Immediate binding: yes" | wc -l )
SUID_IB_NO=$(cat /tmp/executables_suid_results | grep " Immediate binding" | grep -v " Immediate binding: yes" | wc -l )
SUID_IB_PERCENT=$(awk -vn=$SUID_IB_YES -vm=$SUID_IB_NO 'BEGIN{print((n/(n+m))*100)}')
LIB=$(cat /tmp/libraries_results | grep Position | wc -l )
LIB_SP_YES=$(cat /tmp/libraries_results | grep " Stack protected: yes" | wc -l )
LIB_SP_NO=$(cat /tmp/libraries_results | grep " Stack protected" | grep -v " Stack protected: yes" | wc -l )
LIB_SP_PERCENT=$(awk -vn=$LIB_SP_YES -vm=$LIB_SP_NO 'BEGIN{print((n/(n+m))*100)}')
LIB_FS_YES=$(cat /tmp/libraries_results | grep " Fortify Source functions: yes" | wc -l )
LIB_FS_NO=$(cat /tmp/libraries_results | grep " Fortify Source functions" | grep -v " Fortify Source functions: yes" | wc -l )
LIB_FS_PERCENT=$(awk -vn=$LIB_FS_YES -vm=$LIB_FS_NO 'BEGIN{print((n/(n+m))*100)}')
LIB_ROR_YES=$(cat /tmp/libraries_results | grep " Read-only relocations: yes" | wc -l )
LIB_ROR_NO=$(cat /tmp/libraries_results | grep " Read-only relocations" | grep -v " Read-only relocations: yes" | wc -l )
LIB_ROR_PERCENT=$(awk -vn=$LIB_ROR_YES -vm=$LIB_ROR_NO 'BEGIN{print((n/(n+m))*100)}')
LIB_IB_YES=$(cat /tmp/libraries_results | grep " Immediate binding: yes" | wc -l )
LIB_IB_NO=$(cat /tmp/libraries_results | grep " Immediate binding" | grep -v " Immediate binding: yes" | wc -l )
LIB_IB_PERCENT=$(awk -vn=$LIB_IB_YES -vm=$LIB_IB_NO 'BEGIN{print((n/(n+m))*100)}')
lsb_release -a
uname -r 
echo -e "Type\tFeature\tFiles\tYES\tNO\tPERCENT" >> /tmp/binary_report
echo -e "Executable\tPositionIndependent\t$EXECUTABLES\t$EXECUTABLES_PIE_YES\t$EXECUTABLES_PIE_NO\t$EXECUTABLES_PIE_PERCENT" >> /tmp/binary_report
echo -e "Executable\tStackProtected\t$EXECUTABLES\t$EXECUTABLES_SP_YES\t$EXECUTABLES_SP_NO\t$EXECUTABLES_SP_PERCENT" >> /tmp/binary_report
echo -e "Executable\tFortifySource\t$EXECUTABLES\t$EXECUTABLES_FS_YES\t$EXECUTABLES_FS_NO\t$EXECUTABLES_FS_PERCENT" >> /tmp/binary_report
echo -e "Executable\tReadOnlyRelocations\t$EXECUTABLES\t$EXECUTABLES_ROR_YES\t$EXECUTABLES_ROR_NO\t$EXECUTABLES_ROR_PERCENT" >> /tmp/binary_report
echo -e "Executable\tImmediateBinding\t$EXECUTABLES\t$EXECUTABLES_IB_YES\t$EXECUTABLES_IB_NO\t$EXECUTABLES_IB_PERCENT" >> /tmp/binary_report
echo -e "SUID\tPositionIndependent\t$SUID\t$SUID_PIE_YES\t$SUID_PIE_NO\t$SUID_PIE_PERCENT" >>/tmp/binary_report
echo -e "SUID\tStackProtected\t$SUID\t$SUID_SP_YES\t$SUID_SP_NO\t$SUID_SP_PERCENT" >>/tmp/binary_report
echo -e "SUID\tFortifySource\t$SUID\t$SUID_FS_YES\t$SUID_FS_NO\t$SUID_FS_PERCENT" >>/tmp/binary_report
echo -e "SUID\tReadOnlyRelocations\t$SUID\t$SUID_ROR_YES\t$SUID_ROR_NO\t$SUID_ROR_PERCENT" >>/tmp/binary_report
echo -e "SUID\tImmediateBinding\t$SUID\t$SUID_IB_YES\t$SUID_IB_NO\t$SUID_IB_PERCENT" >>/tmp/binary_report
echo -e "Library\tStackProtected\t$LIB\t$LIB_SP_YES\t$LIB_SP_NO\t$LIB_SP_PERCENT" >>/tmp/binary_report
echo -e "Library\tFortifySource\t$LIB\t$LIB_FS_YES\t$LIB_FS_NO\t$LIB_FS_PERCENT" >>/tmp/binary_report
echo -e "Library\tReadOnlyRelocations\t$LIB\t$LIB_ROR_YES\t$LIB_ROR_NO\t$LIB_ROR_PERCENT" >>/tmp/binary_report
echo -e "Library\tImmediateBinding\t$LIB\t$LIB_IB_YES\t$LIB_IB_NO\t$LIB_IB_PERCENT" >>/tmp/binary_report
column -t /tmp/binary_report
rm /tmp/binary_report

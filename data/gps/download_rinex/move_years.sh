year=2017
rinex_code="${year:2:2}d"

for f in `ls *.${rinex_code}.Z`
do
    mv $f ${year}/
done

year=2018
rinex_code="${year:2:2}d"

for f in `ls *.${rinex_code}.Z`
do
    mv $f ${year}/
done


year=2019
rinex_code="${year:2:2}d"

for f in `ls *.${rinex_code}.Z`
do
    mv $f ${year}/
done

year=2020
rinex_code="${year:2:2}d"

for f in `ls *.${rinex_code}.Z`
do
    mv $f ${year}/
done


year=2021
rinex_code="${year:2:2}d"

for f in `ls *.${rinex_code}.Z`
do
    mv $f ${year}/
done


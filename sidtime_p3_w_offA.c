#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int     xsAMPM[2] = { 390, 396 };
int     xeAMPM[2] = { 394, 400 };
int	xdAMPM[2];
int	yAMPM  = 95;
int	ydAMPM = 6;
int	Show24HourTime = 0;
int	ShowGreenwichTime = 0;
int	ShowSiderealTime = 0;
double	Longitude;
int	Flag = 0;
int	Beep = 0;
int	Volume = 100;
int	ShowSeconds = 1;
int	UseLowColorPixmap = 0;
int	UseArial = 0;
int	UseComicSans = 0;
int	UseTekton = 0;
int	UseLuggerbug = 0;
int	UseJazzPoster = 0;
int     GotFirstClick1, GotDoubleClick1;
int     GotFirstClick2, GotDoubleClick2;
int     GotFirstClick3, GotDoubleClick3;
int     DblClkDelay;
int     HasExecute = 0;		/* controls perf optimization */
char	ExecuteCommand[1024];


int main(int argc, char *argv[]) {


    struct tm		*Time;
    int			i, n, wid, extrady, extradx;
    int 		Year, Month, DayOfWeek, DayOfMonth, OldDayOfMonth;
    int			Hours, Mins, Secs, OldSecs, digit, xoff, D[10], xsize;
    long		CurrentLocalTime;
    double		UT, TU, TU2, TU3, T0, gmst, jd(), hour24(), gmst1;

	Longitude = atof(argv[2]); // 8112 Viola
//                CurrentLocalTime = time(CurrentTime);
                CurrentLocalTime = time(NULL);
	        Time = gmtime(&CurrentLocalTime);
	        DayOfMonth = Time->tm_mday-1;
	        DayOfWeek = Time->tm_wday;
		Year  = Time->tm_year + 1900; /* this is NOT a Y2K bug */
	        Month = Time->tm_mon;
	        Hours = Time->tm_hour;
	        Mins  = Time->tm_min;
	        Secs  = Time->tm_sec;
		UT = (double)Hours + (double)Mins/60.0 + (double)Secs/3600.0;

		/*
		 *  Compute Greenwich Mean Sidereal Time (gmst)
		 *  The TU here is number of Julian centuries
		 *  since 2000 January 1.5
		 *  From the 1996 astronomical almanac
		 */
		TU = (jd(Year, Month+1, DayOfMonth+1, 0.0) - 2451545.0)/36525.0;
		TU2 = TU*TU;
		TU3 = TU2*TU;
		T0 = (6.0 + 41.0/60.0 + 50.54841/3600.0) + 8640184.812866/3600.0*TU
			+ 0.093104/3600.0*TU2 - 6.2e-6/3600.0*TU3;

		gmst = hour24(hour24(T0) + UT*1.002737909 + Longitude/15.0);
//		gmst = hour24(hour24(T0) + UT*1.002737909 );
//		gmst += 0.68812018;
//p		gmst += 0.88812018;
//0319		gmst += 0.675378;
//10042021		gmst += 0.474;
//11142021		gmst += 0.707;
//		gmst += atof(argv[1]); //0.707;
////		printf("\n\nTime delta = %f\n\n", atof(argv[1]));
		if(gmst >=24.0) gmst -=24.0;
		gmst1 = gmst;
//		printf(" No off = %.7f",gmst);
////		printf("%.7f",gmst);
		Hours = (int)gmst;
		gmst  = (gmst - (double)Hours)*60.0;
		Mins  = (int)gmst;
		gmst  = (gmst - (double)Mins)*60.0;
		Secs  = (int)gmst;
////		printf("   = %.2d:%.2d:%.2d.00\n",Hours,Mins,Secs);
              gmst1 += atof(argv[1]); //0.707;
                //printf("\n\nTime delta = %f\n\n", atof(argv[1]));
                if(gmst1 >=24.0) gmst1 -=24.0;
//                printf("W off = %.7f",gmst1);
                printf("%.7f",gmst1);
                Hours = (int)gmst1;
                gmst1  = (gmst1- (double)Hours)*60.0;
                Mins  = (int)gmst1;
                gmst1  = (gmst1 - (double)Mins)*60.0;
                Secs  = (int)gmst1;
//              printf("  = %.2d:%.2d:%.2d.00\n",Hours,Mins,Secs);


}


/*
 *  Compute the Julian Day number for the given date.
 *  Julian Date is the number of days since noon of Jan 1 4713 B.C.
 */
double jd(ny, nm, nd, UT)
int ny, nm, nd;
double UT;
{
        double A, B, C, D, JD, day;

        day = nd + UT/24.0;


        if ((nm == 1) || (nm == 2)){
                ny = ny - 1;
                nm = nm + 12;
        }

        if (((double)ny+nm/12.0+day/365.25)>=(1582.0+10.0/12.0+15.0/365.25)){
                        A = ((int)(ny / 100.0));
                        B = 2.0 - A + (int)(A/4.0);
        }
        else{
                        B = 0.0;
        }

        if (ny < 0.0){
                C = (int)((365.25*(double)ny) - 0.75);
        }
        else{
                C = (int)(365.25*(double)ny);
        }

        D = (int)(30.6001*(double)(nm+1));


        JD = B + C + D + day + 1720994.5;
        return(JD);

}


double hour24(hour)
double hour;
{
        int n;

        if (hour < 0.0){
                n = (int)(hour/24.0) - 1;
                return(hour-n*24.0);
        }
        else if (hour > 24.0){
                n = (int)(hour/24.0);
                return(hour-n*24.0);
        }
        else{
                return(hour);
        }
}

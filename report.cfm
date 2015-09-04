<cfsilent>
	<cfquery name="report_08" datasource="Parse">
		SELECT h.*, MONTH(EffectiveDate) as Month, DATENAME(month, EffectiveDate) as MonthOfYearAsString
		FROM History h
		WHERE EffectiveDate >= '01-01-2008' AND EffectiveDate <= '12-31-2008'
		ORDER BY h.EffectiveDate
	</cfquery>
	<cfquery name="report_09" datasource="Parse">
		SELECT h.*, MONTH(EffectiveDate) as Month, DATENAME(month, EffectiveDate) as MonthOfYearAsString
		FROM History h
		WHERE EffectiveDate >= '01-01-2009' AND EffectiveDate <= '12-31-2009'
		ORDER BY h.EffectiveDate
	</cfquery>	
	<cfquery name="report_10" datasource="Parse">
		SELECT h.*, MONTH(EffectiveDate) as Month, DATENAME(month, EffectiveDate) as MonthOfYearAsString
		FROM History h
		WHERE EffectiveDate >= '01-01-2010' AND EffectiveDate <= '12-31-2010'
		ORDER BY h.EffectiveDate
	</cfquery>	
</cfsilent>

<table>
<tr>

<td>
<cfchart title="2008 - Class Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts By Class" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_08" seriesLabel="Druid" itemColumn="MonthOfYearAsString" valuecolumn="NumDruids" seriesColor="##ff8000" />
	<cfchartseries type="line" query="report_08" seriesLabel="Hunter" itemColumn="MonthOfYearAsString" valuecolumn="NumHunters" seriesColor="##008000" />
	<cfchartseries type="line" query="report_08" seriesLabel="Mage" itemColumn="MonthOfYearAsString" valuecolumn="NumMages" seriesColor="##0080c0" />
	<cfchartseries type="line" query="report_08" seriesLabel="Paladin" itemColumn="MonthOfYearAsString" valuecolumn="NumPaladins" seriesColor="##ff00ff" />
	<cfchartseries type="line" query="report_08" seriesLabel="Priest" itemColumn="MonthOfYearAsString" valuecolumn="NumPriests" seriesColor="##ffffff" />
	<cfchartseries type="line" query="report_08" seriesLabel="Rogue" itemColumn="MonthOfYearAsString" valuecolumn="NumRogues" seriesColor="##ffff00" />
	<cfchartseries type="line" query="report_08" seriesLabel="Shaman" itemColumn="MonthOfYearAsString" valuecolumn="NumShamans" seriesColor="##0000ff" />
	<cfchartseries type="line" query="report_08" seriesLabel="Warlock" itemColumn="MonthOfYearAsString" valuecolumn="NumWarlocks" seriesColor="##800080" />
	<cfchartseries type="line" query="report_08" seriesLabel="Warrior" itemColumn="MonthOfYearAsString" valuecolumn="NumWarriors" seriesColor="##804000" />
</cfchart>
</td>
<td>
<cfchart title="2009 - Class Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts By Class" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_09" seriesLabel="Druid" itemColumn="MonthOfYearAsString" valuecolumn="NumDruids" seriesColor="##ff8000" />
	<cfchartseries type="line" query="report_09" seriesLabel="Hunter" itemColumn="MonthOfYearAsString" valuecolumn="NumHunters" seriesColor="##008000" />
	<cfchartseries type="line" query="report_09" seriesLabel="Mage" itemColumn="MonthOfYearAsString" valuecolumn="NumMages" seriesColor="##0080c0" />
	<cfchartseries type="line" query="report_09" seriesLabel="Paladin" itemColumn="MonthOfYearAsString" valuecolumn="NumPaladins" seriesColor="##ff00ff" />
	<cfchartseries type="line" query="report_09" seriesLabel="Priest" itemColumn="MonthOfYearAsString" valuecolumn="NumPriests" seriesColor="##ffffff" />
	<cfchartseries type="line" query="report_09" seriesLabel="Rogue" itemColumn="MonthOfYearAsString" valuecolumn="NumRogues" seriesColor="##ffff00" />
	<cfchartseries type="line" query="report_09" seriesLabel="Shaman" itemColumn="MonthOfYearAsString" valuecolumn="NumShamans" seriesColor="##0000ff" />
	<cfchartseries type="line" query="report_09" seriesLabel="Warlock" itemColumn="MonthOfYearAsString" valuecolumn="NumWarlocks" seriesColor="##800080" />
	<cfchartseries type="line" query="report_09" seriesLabel="Warrior" itemColumn="MonthOfYearAsString" valuecolumn="NumWarriors" seriesColor="##804000" />
	<cfchartseries type="line" query="report_09" seriesLabel="Warrior" itemColumn="MonthOfYearAsString" valuecolumn="NumDeathKnights" seriesColor="##ff0000" />	
</cfchart>
</td>
<td>
<cfchart title="2010 - Class Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts By Class" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_10" seriesLabel="Druid" itemColumn="MonthOfYearAsString" valuecolumn="NumDruids" seriesColor="##ff8000" />
	<cfchartseries type="line" query="report_10" seriesLabel="Hunter" itemColumn="MonthOfYearAsString" valuecolumn="NumHunters" seriesColor="##008000" />
	<cfchartseries type="line" query="report_10" seriesLabel="Mage" itemColumn="MonthOfYearAsString" valuecolumn="NumMages" seriesColor="##0080c0" />
	<cfchartseries type="line" query="report_10" seriesLabel="Paladin" itemColumn="MonthOfYearAsString" valuecolumn="NumPaladins" seriesColor="##ff00ff" />
	<cfchartseries type="line" query="report_10" seriesLabel="Priest" itemColumn="MonthOfYearAsString" valuecolumn="NumPriests" seriesColor="##ffffff" />
	<cfchartseries type="line" query="report_10" seriesLabel="Rogue" itemColumn="MonthOfYearAsString" valuecolumn="NumRogues" seriesColor="##ffff00" />
	<cfchartseries type="line" query="report_10" seriesLabel="Shaman" itemColumn="MonthOfYearAsString" valuecolumn="NumShamans" seriesColor="##0000ff" />
	<cfchartseries type="line" query="report_10" seriesLabel="Warlock" itemColumn="MonthOfYearAsString" valuecolumn="NumWarlocks" seriesColor="##800080" />
	<cfchartseries type="line" query="report_10" seriesLabel="Warrior" itemColumn="MonthOfYearAsString" valuecolumn="NumWarriors" seriesColor="##804000" />
	<cfchartseries type="line" query="report_10" seriesLabel="Warrior" itemColumn="MonthOfYearAsString" valuecolumn="NumDeathKnights" seriesColor="##ff0000" />	
</cfchart>
</td>
</tr>
<tr>

<td>
<cfchart title="2008 - Faction Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts By Faction" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_08" seriesLabel="Alliance" itemColumn="MonthOfYearAsString" valuecolumn="NumAlliance" seriesColor="blue" />
	<cfchartseries type="line" query="report_08" seriesLabel="Horde" itemColumn="MonthOfYearAsString" valuecolumn="NumHorde" seriesColor="##ff8000" />
</cfchart>
</td>
<td>
<cfchart title="2009 - Faction Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts By Faction" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_09" seriesLabel="Alliance" itemColumn="MonthOfYearAsString" valuecolumn="NumAlliance" seriesColor="blue" />
	<cfchartseries type="line" query="report_09" seriesLabel="Horde" itemColumn="MonthOfYearAsString" valuecolumn="NumHorde" seriesColor="##ff8000" />
</cfchart>
</td>
<td>
<cfchart title="2010 - Faction Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts By Faction" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_10" seriesLabel="Alliance" itemColumn="MonthOfYearAsString" valuecolumn="NumAlliance" seriesColor="blue" />
	<cfchartseries type="line" query="report_10" seriesLabel="Horde" itemColumn="MonthOfYearAsString" valuecolumn="NumHorde" seriesColor="##ff8000" />
</cfchart>
</td>
</tr>
<tr>

<td>
<cfchart title="2008 - Server Type Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts By Server Type" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_08" seriesLabel="PvP" itemColumn="MonthOfYearAsString" valuecolumn="NumPvP" seriesColor="red" />
	<cfchartseries type="line" query="report_08" seriesLabel="PvE" itemColumn="MonthOfYearAsString" valuecolumn="NumPvE" seriesColor="##FF00FF" />
</cfchart>
</td>
<td>
<cfchart title="2009 - Server Type Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts By Server Type" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_09" seriesLabel="PvP" itemColumn="MonthOfYearAsString" valuecolumn="NumPvP" seriesColor="red" />
	<cfchartseries type="line" query="report_09" seriesLabel="PvE" itemColumn="MonthOfYearAsString" valuecolumn="NumPvE" seriesColor="##FF00FF" />
</cfchart>
</td>
<td>
<cfchart title="2010 - Server Type Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts By Server Type" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_10" seriesLabel="PvP" itemColumn="MonthOfYearAsString" valuecolumn="NumPvP" seriesColor="red" />
	<cfchartseries type="line" query="report_10" seriesLabel="PvE" itemColumn="MonthOfYearAsString" valuecolumn="NumPvE" seriesColor="##FF00FF" />
</cfchart>
</td>
</tr>
<tr>

<td>
<cfchart title="2008 - Region Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts by Region" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_08" seriesLabel="USA" itemColumn="MonthOfYearAsString" valuecolumn="NumUS" seriesColor="red" />
	<cfchartseries type="line" query="report_08" seriesLabel="Europe" itemColumn="MonthOfYearAsString" valuecolumn="NumEU" seriesColor="blue" />
</cfchart>
</td>
<td>
<cfchart title="2009 - Region Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts by Region" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_09" seriesLabel="USA" itemColumn="MonthOfYearAsString" valuecolumn="NumUS" seriesColor="red" />
	<cfchartseries type="line" query="report_09" seriesLabel="Europe" itemColumn="MonthOfYearAsString" valuecolumn="NumEU" seriesColor="blue" />
</cfchart>
</td>
<td>
<cfchart title="2010 - Region Recruitment Info" format="png" xaxistitle="Month" yaxistitle="No. Posts by Region" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_10" seriesLabel="USA" itemColumn="MonthOfYearAsString" valuecolumn="NumUS" seriesColor="red" />
	<cfchartseries type="line" query="report_10" seriesLabel="Europe" itemColumn="MonthOfYearAsString" valuecolumn="NumEU" seriesColor="blue" />
</cfchart>
</td>
</tr>
<tr>

<td>
<cfchart title="2008 - Total Posts" format="png" xaxistitle="Month" yaxistitle="No. Posts" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_08" seriesLabel="Post Count" itemColumn="MonthOfYearAsString" valuecolumn="NumPosts" seriesColor="##008000" />
</cfchart>
</td>
<td>
<cfchart title="2009 - Total Posts" format="png" xaxistitle="Month" yaxistitle="No. Posts" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_09" seriesLabel="Post Count" itemColumn="MonthOfYearAsString" valuecolumn="NumPosts" seriesColor="##008000" />
</cfchart>
</td>
<td>
<cfchart title="2010 - Total Posts" format="png" xaxistitle="Month" yaxistitle="No. Posts" chartWidth="600" chartHeight="300" dataBackgroundColor="##8c8c8c">
	<cfchartseries type="line" query="report_10" seriesLabel="Post Count" itemColumn="MonthOfYearAsString" valuecolumn="NumPosts" seriesColor="##008000" />
</cfchart>
</td>
</tr>
</table>
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
<script type="text/javascript">
_uacct = "UA-3535784-1";
urchinTracker();
</script>
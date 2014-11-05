package utils;

import java.util.Date;

import lazyj.Format;

import lia.Monitor.Store.Fast.DB;

/**
 * @author costing
 */
public class BuildVersion {

	/**
	 * @param date
	 * @return timestamp from a date, in any known format
	 */
	public static long getTimestamp(final String date) {
		final Date d = Format.parseDate(date);

		if (d == null)
			return 0;

		return d.getTime();
	}

	/**
	 * @param version
	 * @param timestamp
	 * @return the version for this timestamp
	 */
	public static synchronized int getVersion(final String version, final long timestamp) {
		final DB db = new DB();

		final int time = (int) (timestamp / 1000);

		db.query("SELECT vernumber FROM buildsystem_versions WHERE version='" + Format.escSQL(version)
			+ "' AND lastchange=" + time + ";");

		if (db.moveNext()) {
			return db.geti(1);
		}

		db.query("SELECT vernumber FROM buildsystem_versions WHERE version='" + Format.escSQL(version)
			+ "' AND lastchange<" + time + " ORDER BY lastchange DESC LIMIT 1;");

		int iPrevVersion = -1;

		if (db.moveNext()) {
			iPrevVersion = db.geti(1);
		}

		db.query("SELECT vernumber FROM buildsystem_versions WHERE version='" + Format.escSQL(version)
			+ "' AND lastchange>" + time + " ORDER BY lastchange ASC LIMIT 1;");

		if (db.moveNext()) {
			// there is something newer
			final int iNextVersion = db.geti(1);

			if (iPrevVersion < 0)
				return iNextVersion - 1;
			
			return iPrevVersion;
		}

		// we have to insert the new version

		final int iNewVersion = (iPrevVersion < 0 ? 1 : iPrevVersion + 1);

		if (db.syncUpdateQuery("INSERT INTO buildsystem_versions(version, lastchange, vernumber) VALUES ('"
			+ Format.escSQL(version) + "', " + time + ", " + iNewVersion + ");")) {
			return iNewVersion;
		}

		// hmm, it failed, maybe it got inserted in the mean time? (shouldn't
		// but ... let's be very sure)
		db.query("SELECT vernumber FROM buildsystem_versions WHERE version='" + Format.escSQL(version)
			+ "' AND lastchange=" + time + ";");

		if (db.moveNext())
			return db.geti(1);

		return 0;
	}

	/**
	 * @param args
	 */
	public static void main(String args[]) {
		System.err.println(getVersion("v2-18", 1000000));
		System.err.println(getVersion("v2-18", 500000));
		System.err.println(getVersion("v2-18", 2000000));
		System.err.println(getVersion("v2-18", 1500000));
		System.err.println(getVersion("v2-18", 3000000));
		System.err.println(getVersion("v2-18", 1500000));
	}

}

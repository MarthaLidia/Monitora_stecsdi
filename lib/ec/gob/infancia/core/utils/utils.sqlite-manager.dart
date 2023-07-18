/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-27
/// @Updated: 2022-07-11

part of ec.gob.infancia.ecuadorsincero.utils;

/// Utilitario que gestiona y configura la base local de la app.
class UtilsSqlite {
  static Future<Database> open() async => openDatabase(
        path.join(await getDatabasesPath(), 'sincero.db'),
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE User (
              u_username TEXT PRIMARY KEY,
              u_enabled INTEGER,
              u_accountNonExpired INTEGER,
              u_accountNonLocked INTEGER,
              u_credentialsNonExpired INTEGER,
              u_authorities TEXT,
              u_claims TEXT,
              u_id INTEGER,
              u_status INTEGER,
              u_user TEXT,
              u_date TEXT,
              u_documentTypeId TEXT,
              u_documentTypeName TEXT,
              u_document TEXT,
              u_fullName TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE Question (
              q_id TEXT,
              q_module TEXT,
              q_parent TEXT,
              q_order INTEGER,
              q_label TEXT,
              q_type TEXT,
              q_visible INTEGER,
              q_enabledBy INTEGER,
              q_textTheme TEXT,
              q_description TEXT,
              q_children INTEGER,
              q_answers TEXT,
              PRIMARY KEY(q_id, q_module)
            )
          ''');

          await db.execute('''
            CREATE TABLE FormHeader (
              fh_id INTEGER,
              fh_creationUser TEXT,
              fh_creationDate TEXT,
              fh_module TEXT,
              fh_moduleName TEXT,
              fh_latitude REAL,
              fh_longitude REAL,
              fh_datetime TEXT,
              fh_complete INTEGER,
              fh_rsRequest INTEGER,
              fh_comments TEXT,
              fh_username TEXT,
              fh_userFullName TEXT,
              fh_tryNumber INTEGER,
              fh_reverseAddress TEXT,
              fh_address TEXT,
              fh_ready INTEGER DEFAULT 0,
              fh_code TEXT,
              fh_dpa TEXT,
              fh_updateMessage TEXT,
              fh_firma_base64 TEXT,
              fh_audio_ci TEXT,
              PRIMARY KEY(fh_id, fh_module)
            )
          ''');

          await db.execute('''
            CREATE TABLE FormAnswer (
              fa_header INTEGER,
              fa_question TEXT,
              fa_answer INTEGER,
              fa_code INTEGER,
              fa_other TEXT,
              fa_questionParent TEXT,
              fa_module TEXT,
              fa_complete INTEGER,
              fa_id INTEGER,
              fa_creationUser TEXT,
              fa_creationDate TEXT,
              fa_updateMessage TEXT,
              fa_temp TEXT,
              PRIMARY KEY(fa_header, fa_question, fa_code)
            )
          ''');

          await db.execute('''
            CREATE TABLE FormPersonInfo (
              fpi_header INTEGER,
              fpi_code INTEGER,
              fpi_document TEXT,
              fpi_lastName TEXT,
              fpi_name TEXT,
              fpi_ready INTEGER,
              fpi_gender INTEGER DEFAULT 0,
              fpi_person_answers INTEGER,
              fpi_woman_answers INTEGER,
              fpi_child_answers INTEGER,
              PRIMARY KEY(fpi_header, fpi_code)
            )
          ''');

          await db.execute('''
            CREATE TABLE PeopleData (
              document TEXT,
              lastName TEXT,
              name TEXT,
              gender INTEGER,
              birthDate TEXT,
              location TEXT,
              PRIMARY KEY(document)
            )
          ''');

          await db.execute('''
            CREATE TABLE RsData (
              certificate TEXT,
              document TEXT,
              lastName TEXT,
              name TEXT,
              stateId TEXT,
              cityId TEXT,
              locationId TEXT,
              PRIMARY KEY(document)
            )
          ''');

          await db.execute('''
            CREATE TABLE FormRsInfo (
              frsi_header INTEGER,
              frsi_deficit01 TEXT,
              frsi_deficit02 TEXT,
              frsi_deficit03 TEXT,
              frsi_water INTEGER,
              frsi_hygiene INTEGER,
              frsi_salary INTEGER,
              frsi_food INTEGER,
              frsi_light INTEGER,
              frsi_alreadyInRs INTEGER,
              PRIMARY KEY(frsi_header)
            )
          ''');

          await db.execute('''
            CREATE TABLE Location (
              l_state TEXT,
              l_stateLabel TEXT,
              l_city TEXT,
              l_cityLabel TEXT,
              l_location TEXT,
              l_locationLabel TEXT PRIMARY KEY
            )
          ''');

          await db.execute('''
            CREATE TABLE AnswerValidation (
              av_id INTEGER PRIMARY KEY,
              av_module TEXT,
              av_conditionQuestion TEXT,
              av_conditionAnswer TEXT,
              av_restrictionQuestion TEXT,
              av_restrictionAnswer TEXT,
              av_message TEXT
            )
          ''');

          for (var i = 0; i < version; i++) {
            await addUpgrade(db, i + 1);
          }
        },
        onUpgrade: (db, _, newVersion) async {
          await addUpgrade(db, newVersion);
        },
        version: 2,
      );

  static addUpgrade(Database db, int newVersion) async {
    switch (newVersion) {
      case 2:
        await db.execute('DROP TABLE Location');
        await db.execute('''
            CREATE TABLE Location (
              l_state TEXT,
              l_stateLabel TEXT,
              l_city TEXT,
              l_cityLabel TEXT,
              l_location TEXT,
              l_locationLabel TEXT,
              PRIMARY KEY(l_state, l_city, l_location)
            )
          ''');
        break;
    }
  }
}

package com.goldhuman.service;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.goldhuman.auth.AuthFilter;
import com.goldhuman.service.interfaces.LogInfo;
import com.goldhuman.util.DBPool;

public class GMServiceImpl {

    private static final Log log = LogFactory.getLog(GMServiceImpl.class);

    public boolean setDoubleExp(double doubleExp, LogInfo logInfo) {
        log.info("setDoubleExp, doubleExp=" + doubleExp + ",operator=" + AuthFilter.getRemoteUser(logInfo.request));
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        try {
            conn = DBPool.getConnection();
            pstmt = conn.prepareStatement("UPDATE server_info SET double_exp=?");
            pstmt.setDouble(1, doubleExp);
            int ret = pstmt.executeUpdate();
            log.info("setDoubleExp, ret=" + ret);
            success = ret > 0;
        } catch (SQLException sqle) {
            log.error("setDoubleExp, SQLException", sqle);
           // Re-throw the exception to make sure the caller knows.
           //throw new RuntimeException("setDoubleExp failed", sqle);
        } finally {
           DBPool.close(conn, pstmt);
        }
      log.info("setDoubleExp, success=" + success);
        return success;
    }

    public double getDoubleExp(LogInfo logInfo) {
       log.info("getDoubleExp, operator=" + AuthFilter.getRemoteUser(logInfo.request));
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        double doubleExp = 1.0;
        try {
            conn = DBPool.getConnection();
            pstmt = conn.prepareStatement("SELECT double_exp FROM server_info");
            rs = pstmt.executeQuery();
            if (rs.next()) {
                doubleExp = rs.getDouble(1);
            }
           log.info("getDoubleExp, doubleExp=" + doubleExp);
           return doubleExp;
        } catch (SQLException sqle) {
            log.error("getDoubleExp, SQLException", sqle);
            // Re-throw the exception to make sure the caller knows.
             //throw new RuntimeException("getDoubleExp failed", sqle);
        } finally {
            DBPool.close(conn, pstmt, rs);
        }
       log.info("getDoubleExp, returning=" + doubleExp);
        return doubleExp;
    }

    public boolean setw2iexperience(Double experience, LogInfo logInfo) {
        log.info("setw2iexperience, experience=" + experience + ",operator=" + AuthFilter.getRemoteUser(logInfo.request));
        Connection conn = null;
        CallableStatement cstmt = null;
        boolean success = false;
        int updateCount = 0;
        try {
            conn = DBPool.getConnection();
            cstmt = conn.prepareCall("{call set_w2i_exp(?)}");
            cstmt.setDouble(1, experience);
            boolean hasResults = cstmt.execute();
            if (!hasResults){
                updateCount = cstmt.getUpdateCount();
                log.info("setw2iexperience, rows updated=" + updateCount);
                if(updateCount > 0){
                  success = true;
                }
                else {
                  log.warn("setw2iexperience, no rows updated");
                }
            }
            else {
                log.warn("setw2iexperience, Stored Procedure returned a result set.");
            }
        }
       catch (SQLException sqle) {
           log.error("setw2iexperience, SQLException", sqle);
         // Re-throw the exception to make sure the caller knows.
         // throw new RuntimeException("setw2iexperience failed", sqle);
        } finally {
            DBPool.close(conn, cstmt);
        }
        log.info("setw2iexperience, success=" + success);
        return success;
    }

    public Double getw2iexperience(LogInfo logInfo) {
        log.info("getw2iexperience, operator=" + AuthFilter.getRemoteUser(logInfo.request));
        Connection conn = null;
        CallableStatement cstmt = null;
        ResultSet rs = null;
        Double experience = null;

        try {
            conn = DBPool.getConnection();
            cstmt = conn.prepareCall("{call get_w2i_exp()}");
            boolean ret = cstmt.execute();
            if (ret) {
                rs = cstmt.getResultSet();
                if (rs.next()) {
                    experience = rs.getDouble(1);
                }
            }
        } catch (SQLException sqle) {
           log.error("getw2iexperience, SQLException", sqle);
           // Re-throw the exception to make sure the caller knows.
            //throw new RuntimeException("getw2iexperience failed", sqle);
        } finally {
             DBPool.close(conn, cstmt,rs);
        }
      log.info("getw2iexperience, experience=" + experience);
        return experience;
    }
}
/*
 * MEncoderVideoFilter.java
 *
 * 請把這個檔案上傳到[dspace-source]/dspace-api/src/main/java/org/dspace/app/mediafilter當中
 *
 * [安裝MEncoder]
 * 修改/etc/yum.repos.d/CentOS-Base.repo
 * 加入以下
[dag]
name=Dag RPM Repository for Red Hat Enterprise Linux
baseurl=http://apt.sw.be/redhat/el$releasever/en/$basearch/dag
gpgcheck=1
enabled=1
 *
 * rpm --import http://dag.wieers.com/packages/RPM-GPG-KEY.dag.txt
 *
 * yum install mencoder
 *
 * [安裝codecs]
 *
 * 下載http://www.mplayerhq.hu/MPlayer/releases/codecs/當中的「all-20071007.tar.bz2」(如果有更新日期，不妨下載新版本)
 * wget http://www.mplayerhq.hu/MPlayer/releases/codecs/all-20071007.tar.bz2
 * 解壓縮：tar xvfj all-20071007.tar.bz2 
 * 建立目錄 mkdir -p /usr/lib/codecs (如果之前沒建立的話
 * 移動codecs到目錄中：mv all-20071007/* /usr/lib/codecs
 *
 * [設定MEncoderVideoFilter]
 * 修改[dspace]/config/dspace.cfg
 * 找到「filter.plugins = 」，最後加入「, MEncoder Video Converter」
 * 找到「plugin.named.org.dspace.app.mediafilter.FormatFilter」，最後加入「 org.dspace.app.mediafilter.MEncoderVideoFilter = MEncoder Video Converter」，如果要換行的話，開頭還要補上「/」
 * 在「filter.org.dspace.app.mediafilter.…」設定之後加入一行設定：
filter.org.dspace.app.mediafilter.MEcoderVideoFilter.inputFormats = RM, RMVB, video/3gpp, Video Quicktime
 * 最後加入以下設定
filter.exec.mencoder = mencoder
filter.MEncoderVideoFilter.config = -vf scale=320:240 -ffourcc FLV1 -of lavf -lavfopts i_certify_that_my_video_stream_does_not_use_b_frames -ovc lavc -lavcopts vcodec=flv:vbitrate=200 -srate 22050 -oac lavc -lavcopts acodec=mp3:abitrate=56
 *
 * 別忘了重新編譯DSpace Source，祝您使用愉快
 */
package org.dspace.app.mediafilter;

import java.io.InputStream;
import java.net.ConnectException;
import org.apache.log4j.Logger;
import org.dspace.app.mediafilter.MediaFilterUtils;

/*
 * 
 * to do: helpful error messages - can't find mediafilter.cfg - can't
 * instantiate filter - bitstream format doesn't exist
 *  
 */
public class Video2MP4 extends MediaFilter
{
    public String getFilteredName(String oldFilename)
    {
        return oldFilename + ".mp4";
    }

    /**
     * @return String bundle name
     *  
     */
    public String getBundleName()
    {
        return "VIDEO_MOBILE";
    }

    /**
     * @return String bitstreamformat
     */
    public String getFormatString()
    {
        return "MP4";
    }

    /**
     * @return String description
     */
    public String getDescription()
    {
        return "Generated Mobile Preview";
    }

    /**
     * @param source
     *            source input stream
     * 
     * @return InputStream the resulting input stream
     */
    public InputStream getDestinationStream(InputStream source, String name, int id)
            throws Exception
    {
		InputStream bais = MediaFilterUtils.Video2MP4(source, name, id);
        return bais;
    }
}

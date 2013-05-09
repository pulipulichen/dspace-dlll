/*
 * FFmpegAudioFilter.java
 *
 * 請把這個檔案上傳到[dspace-source]/dspace-api/src/main/java/org/dspace/app/mediafilter當中
 *
 * [安裝FFmpeg]
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
 * yum install ffmpeg
 * 
 * [設定FFmpegAudioFilter]
 * 修改[dspace]/config/dspace.cfg
 * 找到「filter.plugins = 」，最後加入「, FFmpeg Audio Converter」
 * 找到「plugin.named.org.dspace.app.mediafilter.FormatFilter」，最後加入「 org.dspace.app.mediafilter.FFmpegAudioFilter = FFmpeg Audio Converter」，如果要換行的話，開頭還要補上「/」
 * 在「filter.org.dspace.app.mediafilter.…」設定之後加入一行設定：
filter.org.dspace.app.mediafilter.FFmpegAudioFilter.inputFormats = MP3, AAC, FLAC, OGG, WMA, WAV, M4A
 * 最後加入以下設定
filter.exec.ffmpeg = ffmpeg
filter.FFmpegAudioFilter.config = -ar 22050
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
public class Audio2MP3 extends MediaFilter
{
    public String getFilteredName(String oldFilename)
    {
        return oldFilename + ".mp3";
    }

    /**
     * @return String bundle name
     *  
     */
    public String getBundleName()
    {
        return "AUDIO_PREVIEW";
    }

    /**
     * @return String bitstreamformat
     */
    public String getFormatString()
    {
        return "MP3";
    }

    /**
     * @return String description
     */
    public String getDescription()
    {
        return "Generated Preview";
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
		InputStream bais = MediaFilterUtils.Audio2MP3(source, name, id);
        return bais;
    }
}

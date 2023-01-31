Shader "Unlit/distor"
{
    Properties
    {
        _DistortionPower("Distortion Power", Range(0,0.1)) = 0
        [HDR] _WaterColor("WaterColor", Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrchAlpha
        
        GrabPass 
        {
            "_GrabPassTextureForDistortion"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 grabPos : TEXCOORD1;
                float4 scrPos : TEXCOORD2;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _GrabPassTextureForDistortion;
            float _DistortionPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                /// 描画結果のGrabTextureのテクスチャ座標を使って、後々サンプリングするためにこれをしておく。 （プラットフォーム間の違いを吸収）
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                //NDC空間のxy=>0 ~ wに変換される =>要はクリップ空間(-w~w)を0~wにする。
                
                o.scrPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 distortion = sin(i.uv.y * 50 + _Time.y) * 0.1f;
                distortion *= _DistortionPower;
                float4 grabPos = i.grabPos;
                grabPos.xy = i.grabPos.xy + distortion * 1.5f;
                // 深度テクスチャをサンプリング　＝＞　テキスチャのr成分だけを返している。（深度情報なのでｒだけで十分）
                float depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, grabPos);
                // 深度値を線形にする。（本来は範囲が狭くて微妙らしい）
                float backgroundDepth = LinearEyeDepth(depthSample);
                // 今描画しようとしているピクセルの深度情報（そのままで使えるがプラットフォーム間の差異を吸収しているはず）
                float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.scrPos.z);
                // surfaceDepthの方が奥にある＝＞水面の手前にある＝>0がかえる
                // 水面奥にあれば1を返す
                float depthDiff = saturate(backgroundDepth - surfaceDepth);
                // depthDiffを閾値としる。歪ませるためにdistortionを乗算する。wで除算してないのでここでする。
                float2 uv = (i.grabPos.xy + distortion * depthDiff) / i.grabPos.w;
                return tex2D(_GrabPassTextureForDistortion, uv);
            }
            ENDCG
        }
         Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _WaterColor;

            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _WaterColor;
            }
            ENDCG
        }
    }
}
// 描画結果をGrabPassで取得。
// 描画結果＝＞深度情報を使用して水面下のオブジェクトを歪ませる

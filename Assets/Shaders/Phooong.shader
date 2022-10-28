Shader "Unlit/Phooong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float3 vertexW: TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _Shiness;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToClipPosODS(v.normal);
                o.vertexW = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexW);
                // 法線を出す＝＞正規化
                float3 normal = normalize(i.normal);
                
                float3 light  = normalize(_WorldSpaceLightPos0.w == 0 ?
                              _WorldSpaceLightPos0.xyz :
                              _WorldSpaceLightPos0.xyz - i.vertexW);
                // ワールド座標とカメラのワールド座標を引いて距離を出して視線ベクトルを算出する。
                // UnityWorldSpaceViewDirも距離を出すのは同じ処理をしている。
                float3 view = normalize(_WorldSpaceCameraPos - i.vertexW);
                // reflect＝＞-lightの反射ベクトルを出す
                float3 rflt = normalize(reflect(-light, normal));
                // 拡散反射 クランプする // -1は面が反対方向を向いているのでクランプして描画しないようにする
                float diffuse = saturate(dot(normal, light));
                // 鏡面反射を出す。_Shinessは強度　視線ベクトル,反射ベクトル内積を0~1にクランプする必要がある。
                float specular = pow(saturate(dot(view, rflt)), _Shiness);
                // 環境光
                float3 ambient = ShadeSH9((half4(normal, 1)));
                // 拡散反射光 + 鏡面反射光 + 環境光 => Phongモデル。対して　Lambertは。。
                fixed4 color = diffuse + _MainColor * _LightColor0 * attenuation + specular * _SpecularColor * _LightColor0 * attenuation;
                color.rgb += ambient * _MainColor;
                return color;
                // 拡散反射=>綺麗に反射するわけではなく、微細な凹凸が反射する。
                // 鏡面反射=>反射光は光が直接視界に入ってきたもの。視界ベクトルと反射ベクトルが一致すればするほど
                // 強くなる。反射ベクトルはreflet(光方向, 法線)で出す。視線ベクトルはカメラ座標と頂点のワールド座標の差を正規化する
                // 環境光=>直接的に向きや座標が定義されている光源ではなく、周囲にある物体から反射してきた光のこと。
                // ShadeSH9に法線を入れることで環境光を算出することができる。
            }
            ENDCG
        }
    }
}

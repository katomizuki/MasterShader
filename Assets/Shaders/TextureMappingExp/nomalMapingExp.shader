Shader "Unlit/nomalMapingExp"
{
    Properties
    {
        // テクスチャマップ
 _MainTex ("Texture", 2D) = "white" {}
 // アンビエントカラー
 _Ambient ("Ambient", Range(0,1)) = 0
 // 法線マップ
 _NormalMap ("NormalMap", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            sampler2D _MainTex;

          // ライトカラー
 float4 _LightColor0;
 // アンビエント
 float _Ambient;
 // 法線マップ
 sampler2D _NormalMap;
 struct appdata
 {
 float4 vertex : POSITION;
 float2 uv : TEXCOORD0;
 // 頂点の法線ベクトル
 float4 normal : NORMAL;
 // 頂点の接線ベクトル
 float4 tangent : TANGENT;
 };
 struct v2f
 {
 float2 uv : TEXCOORD0;
 float4 vertex : SV_POSITION;
 // 法線ベクトル
 float3 normalDir : TEXCOORD1;
 // 接線ベクトル
 float3 tangentDir : TEXCOORD2;
 // 従法線ベクトル
 float3 binormalDir : TEXCOORD3;
 }; 

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize(mul(unity_ObjectToWorld,v.tangent));
                o.binormalDir = normalize(cross(o.normalDir, o.tangentDir));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               // 接空間変換行列
 float3x3 tangentTransform =
 float3x3(i.tangentDir, i.binormalDir, i.normalDir);
 // 法線マップからサンプリングした値を法線ベクトルに変換
 float3 normalLocal = UnpackNormal(tex2D(_NormalMap,i.uv)).
xyz;
 // 接空間上の法線ベクトルをワールド空間座標に変換
 float3 normalDirection =
 normalize(mul(normalLocal, tangentTransform));
 // 光源方向ベクトル
 float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
 // 法線 - ライトの角度量
 float NdotL = dot(normalDirection, lightDir);
 // 拡散係数の決定
 float diffuse = max(_Ambient, NdotL); // ★修正
 // テクスチャマップからカラー値をサンプリング
 float4 tex = tex2D(_MainTex, i.uv);
 // カラー値の決定
 fixed4 color = diffuse * tex * _LightColor0; // ★修正
 return color; 
            }
            ENDCG
        }
    }
}

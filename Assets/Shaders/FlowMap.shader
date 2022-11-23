Shader "Unlit/FlowMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FlowMap("Flow Map", 2D) = "white" {}
        _FlowSpeed("Flow Speed", float) = 1.0
        _FlowPower("Flow Power", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _FlowMap;
            float _FlowSpeed;
            float _FlowPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 flowDir = tex2D(_FlowMap, i.uv) - 0.5;
                flowDir *= _FlowPower;
                float progress = frac(_Time.x * _FlowSpeed);
                float2 uv = i.uv + flowDir * progress;
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
